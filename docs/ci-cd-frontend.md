# CI/CD Frontend Next.js
Documentación del pipeline de integración y despliegue continuo del frontend definido en '.github/workflows/' (GitHub Actions).

## Idea central
Hay dos workflows separados, uno por ambiente: uno que corre solo contra `main` (Prod) y otro que corre solo contra `dev` (Dev). Cada uno corre los test unitarios y valida el build de la imagen docker, y si el evento es un push, además construye la imagen, la sube a Artifact Registry y la despliega en Cloud Run.

## Trigger
Los workflows se disparan así:

**Frontend (Prod)**
- Push a `main` --> dispara CI + CD (corre tests, buildea la imagen para Artifact y la despliega en `web-prod`).

**Frontend (Dev)**
- Pull request a `dev` --> dispara el CI (corre tests unitarios y buildea la imagen docker de chequeo).
- Push a `dev` --> dispara el CD correspondiente (corre el CI, si pasa buildea la imagen para Artifact y la despliega en `web-dev`).

## Jobs

### 1. `unit-test-frontend` (CI)
  - Configura Node 20 con cache de npm.
  - Corre `npm ci` para instalar dependencias.
  - El step `npm test` se activará cuando hayan tests.

### 2. `docker-build-check-frontend` (CI)
  - Chequea que el job anterior haya pasado.
  - Construye la imagen solo para verificar que el Dockerfile compila, pasándole `NEXT_PUBLIC_API_BASE_URL` como build-arg desde `vars.API_BASE_URL`. Despues lo destruye.
  - Corre bajo el `environment` de GitHub correspondiente (`production` o `development`), porque necesita resolver la variable `API_BASE_URL` de ese ambiente para poder buildear.
  - Ejecuta un escaneo de vulnerabilidades sobre la imagen utilizando Trivy, buscando vulnerabilidades de severidad HIGH y CRITICAL tanto del sistema operativo como de las dependencias (`os,library`). El escaneo es informativo y no bloquea el pipeline, aunque se detecten vulnerabilidades.

## 3. `build-and-deploy` (CD)
  - Chequea que los dos jobs de CI hayan pasado.
  - En Dev, además valida `if: github.event_name == 'push'`, para que este job no corra en los PR's (que solo disparan CI). En Prod no hace falta ese chequeo porque el workflow ya solo escucha push a `main`.
  - Usa el ambiente de GitHub correspondiente (`production` o `development`), que tiene cargada la variable `API_BASE_URL` de ese ambiente.
  - Autentica contra Google Cloud usando el secret `GCP_SA_KEY` (service account key).
  - Configura docker para autenticar contra Artifact Registry.
  - Define un tag corto a partir del SHA del commit (`sha-<7 caracteres>`), guardado en `SHORT_SHA`.
  - Buildea la imagen tageada con `SHORT_SHA`, pasando de nuevo `NEXT_PUBLIC_API_BASE_URL` como build-arg (necesario porque en Next.js esta variable se hornea en el build, no alcanza con setearla en runtime).
  - Además tagea esa misma imagen como `dev-latest` (Development) o `prod-latest` (Production).
  - Pushea ambos tags (`SHORT_SHA` y `dev-latest`/`prod-latest`) a Artifact Registry. Como Prod y Dev comparten el mismo repositorio de imágenes (`.../ucutalent/frontend`), el tag por SHA permite identificar exactamente de qué build proviene cada imagen,    mientras que `dev-latest` y `prod-latest` siempre apuntan a la versión más reciente de cada ambiente.
  - Deploy a Cloud Run (`web-dev` o `web-prod`, región `us-central1`), usando la imagen tageada por `SHORT_SHA` (no `dev-latest` ni `prod-latest`), para que el despliegue quede asociado a una versión específica y trazable.

## 4. Debuggear
 - Fallo en tests o build check: revisar logs del job correspondiente en la pestaña Actions del PR/commit.
 - Fallo en auth contra GCP: verificar que `GCP_SA_KEY` no haya expirado o que la service account tenga los permisos necesarios (Artifact Registry Writer, Cloud Run Admin).
 - Fallo en el build por `API_BASE_URL` vacía o incorrecta: revisar que la variable `API_BASE_URL` esté seteada en el ambiente de GitHub correspondiente (Settings → Environments → development/production → Variables). Si está vacía, el build no tira error pero el frontend queda apuntando a una URL de API rota.
 - Fallo en el deploy a Cloud Run: revisar que el `SERVICE` (`web-dev`/`web-prod`) exista en Cloud Run y que la imagen recién pusheada esté disponible en Artifact Registry.
 - La imagen se subió pero el servicio no arranca: revisar logs del servicio en Cloud Run (Console → Cloud Run → web-dev/web-prod → Logs). Verificar también el flag `--port=3000`, que tiene que coincidir con el puerto que expone la app de Next.js dentro del contenedor.
 - Trivy reportó vulnerabilidades: revisar la salida del step "Scan Docker image with Trivy" en GitHub Actions. El reporte muestra las vulnerabilidades detectadas (HIGH y CRITICAL) sin bloquear el pipeline.
