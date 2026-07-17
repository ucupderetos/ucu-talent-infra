# UCU Talent — Infra Arquitectura

Estamos utilizando **Google Cloud Platform (GCP)** para alojar tanto el frontend como el backend, con despliegues automáticos gestionados desde **GitHub Actions**.

---

## 1. Servicios de GCP que usamos

| Servicio | ¿Para qué? |
|---|---|
| **Cloud Run** | Corre los contenedores del frontend y del backend. Un servicio por app y por ambiente. |
| **Artifact Registry** | Guarda las imágenes Docker que genera cada build antes de desplegarlas. |
| **Cloud SQL (PostgreSQL)** | Base de datos relacional del backend. |
| **Cloud Storage** | Almacena archivos estáticos y uploads de usuarios. |
| **Secret Manager** | Guarda credenciales (DB, JWT, API keys) que Cloud Run inyecta como variables de entorno. |
| **IAM (Identity and Access Management)** | Controla quién/qué puede hacer qué en el proyecto — incluye la Service Account y el Workload Identity Federation que usa GitHub Actions para desplegar sin contraseñas. |

---

## 2. Ambientes

Por ahora trabajamos con **2 ambientes**, dentro de un único proyecto de GCP (`reto-universitario-2026`):

| Ambiente | Frontend | Backend (API) | Rama que lo dispara |
|---|---|---|---|
| **DEV/QA** | `dev.ucutalent.tech` | `api-dev.ucutalent.tech` | `dev` |
| **PROD** | `www.ucutalent.tech` | `api.ucutalent.tech` | `main` |

`Nuestro dominio es ucutalent.tech`

---

## 3. CI/CD — GitHub Actions

Por ahora el back tiene su workflow en `.github/workflows/`, con 2 jobs (Proximamente para el front tmb):

### CI (Integración Continua) — corre en cada Pull Request y en cada push a `dev`
1. **`unit-test-backend`**: instala Java 21 y corre `./mvnw test`.
2. **`docker-build-check-backend`**: hace un `docker build` local para verificar que el Dockerfile compila, sin subir nada.

### CD (Despliegue Continuo) — corre **solo** en push a `dev`
1. **Autenticación** contra GCP vía **Workload Identity Federation** — GitHub genera un token temporal, GCP lo valida y le presta la identidad de la Service Account `github-deployer`.
2. **Build** de la imagen Docker, etiquetada con el SHA del commit.
3. **Push** de la imagen a un repo de Artifact Registry (`backend-dev`).
4. **Deploy** a Cloud Run (`api-dev`), creando el servicio si no existe o desplegando una nueva versión si ya existe.

```
push/PR a "dev"
      │
      ▼
┌─────────────── CI ───────────────┐
│  unit-test-backend (mvnw test)   │
│  docker-build-check (docker build)│
└─────────────┬─────────────────────┘
              │ solo si event == push
              ▼
┌─────────────── CD ───────────────┐
│  Auth (Workload Identity Federation)│
│  Build imagen                     │
│  Push → Artifact Registry         │
│  Deploy → Cloud Run                │
└────────────────────────────────────┘
```

### Ver con más detalle el diagrama de CI/CD en PlantUML

[Diagrama](https://github.com/ucupderetos/ucu-talent-infra/blob/dev/docs/images/05-infra-arch.png)

---

## 4. Seguridad de los despliegues automáticos

- **Sin claves guardadas**: usamos Workload Identity Federation en vez de un JSON de Service Account Key. Los tokens son temporales y se generan en cada corrida.
- **Repo autorizado explícitamente**: el Provider de GCP solo acepta tokens que digan que vienen de `ucupderetos/ucu-talent-backend`
- **Permisos mínimos**: la Service Account `github-deployer` solo tiene los roles necesarios (`artifactregistry.writer`, `run.admin`, `iam.serviceAccountUser`), nada más.

---

## 5. Próximos pasos

- [ ] Resolver permisos de IAM del usuario github-deployer en el proyecto (rol Owner / Project IAM Admin).
- [ ] Activar el job `build-and-deploy` (actualmente comentado en el workflow hasta confirmar los permisos).
- [ ] Repetir el mismo setup de CI/CD para el repo del frontend.
- [ ] Configurar los Dominios de `ucutalent.tech`