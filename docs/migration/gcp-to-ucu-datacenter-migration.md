# Migración de GCP a servidor propio (Datacenter UCU)

## Descripción

La infraestructura del proyecto fue implementada sobre GCP. Pero la misma arquitectura puede ser desplegada en un servidor propio dentro del datacenter de la UCU, reemplazando los servicios administrados de GCP por sus equivalentes autogestionados (self-hosted).

En este documento se describe el estado actual de la infraestructura en GCP, el componente autogestionado que cumple la misma función en el servidor de la facultad, los cambios que serían necesarios en el código y en los pipelines, y un plan de migración por fases.

A diferencia de una migración entre clouds, acá se pasa de servicios administrados a infraestructura propia: no hay autoscaling automático, no hay balanceo de carga gestionado, y la disponibilidad, los backups y la seguridad pasan a ser responsabilidad nuestra en vez de estar tercerizados.


## Estado actual en GCP

La arquitectura es un monolito, decisión que fue tomada explícitamente por restricciones de tiempo (ver ADR `0001-arquitectura-servicio` en el repositorio del backend). Esto simplifica bastante la migración, ya que no se utilizan Firebase, Pub/Sub, BigQuery, etc. Solamente hay dos servicios corriendo en contenedores, una base de datos relacional y un bucket para el almacenamiento de archivos.

| Componente | Servicio en GCP |
| ---------- | --------------- |
| Backend (API) | Cloud Run (`api-dev` / `api-prod`) |
| Frontend (Next.js) | Cloud Run (`web-dev` / `web-prod`) |
| Registro de imágenes Docker | Artifact Registry |
| Base de datos | Cloud SQL for PostgreSQL |
| Almacenamiento de archivos | Cloud Storage (bucket de CVs y fotos de perfil) |
| Gestión de secretos | Secret Manager |
| Autenticación del CI/CD | Service Account key (`GCP_SA_KEY`) |

La autenticación de la aplicación es propia (JWT con cookie httpOnly).

Los secretos administrados hoy en Secret Manager son las credenciales de base de datos del backend y de Flyway, el `jwt-secret` (uno por ambiente) y las credenciales de correo.
 

## Mapeo de servicios

| Servicio en GCP | Equivalente en el servidor UCU |
| --------------- | ------------------------------- |
| Cloud Run | Docker Compose sobre el servidor, con Nginx como reverse proxy |
| Artifact Registry | Registro Docker privado propio (`registry:2`) o build directo en el servidor sin registro intermedio |
| Cloud SQL for PostgreSQL | PostgreSQL en contenedor (o instalado directo en el SO) con volumen persistente en disco del servidor |
| Cloud Storage (bucket) | Almacenamiento en el filesystem del servidor. |
| Secret Manager | Archivo `.env` con permisos restringidos en el servidor. |
| Service Account | Usuario de deploy con clave SSH dedicada |
| Cloud SQL Auth Proxy | No aplica porque ya tenemos conexión directa a Postgres dentro de la red |
| Balanceo/HTTPS gestionado | Nginx/Traefik + Let's Encrypt (o el certificado que provea la UCU) |

La diferencia más importante frente al mapeo a otro cloud es que acá no hay scale-to-zero ni autoscaling: los contenedores quedan corriendo permanentemente en el servidor, y el dimensionamiento (CPU/RAM que se les asigna) es manual, fijado en el `docker-compose.yml` de producción.

¡Hay que acordarse de buildear la imagen para la arquitectura del servidor de la facultad (generalmente x86_64)!

## Cambios necesarios

### Backend

- Quitar la dependencia `com.google.cloud.sql:postgres-socket-factory` del `pom.xml` y utilizar el driver estándar de PostgreSQL con una URL JDBC directa (`jdbc:postgresql://<host-interno-o-ip>:5432/<db>`). Si el Postgres corre en el mismo servidor (mismo Docker network), el host puede ser directamente el nombre del contenedor.
- Actualizar `spring.datasource.url` en `application.properties` para apuntar al host interno del servidor. El usuario y la contraseña se siguen inyectando por variables de entorno, ahora desde el `.env` del servidor en lugar de Secret Manager.
- Eliminar del `docker-compose.yml` el servicio `cloud-sql-proxy` y las variables asociadas, igual que en local: el backend se conecta directo al contenedor de Postgres por la red interna de Docker.
- Flyway no requiere cambios.
- La variable `PORT` puede dejar de resolverse dinámicamente: en un servidor propio se fija el puerto que expone cada contenedor (por ejemplo `8080`) y Nginx enruta hacia ese puerto interno.

### Frontend

- No tiene dependencias de SDKs de GCP, por lo que la migración es puramente de infraestructura y el Dockerfile no requiere cambios.
- El único cambio es el valor de `NEXT_PUBLIC_API_BASE_URL`, que debe apuntar al dominio o subdominio del backend en el servidor de la UCU. Como se resuelve en tiempo de build, hay que reconstruir la imagen del frontend y no solamente volver a desplegarla.
- L UCU asignaría un dominio publico.

### CI/CD

Al no haber un cloud de por medio, el CI/CD deja de autenticarse contra una API de nube y pasa a desplegar por SSH:

| Actualmente | En el servidor UCU |
| ----------- | -------------------- |
| `google-github-actions/auth` | Clave SSH privada guardada como secret en GitHub Actions |
| `google-github-actions/setup-gcloud` + push a Artifact Registry | `docker build` local en el runner y `docker save` + `scp`, o build directo en el servidor vía SSH |
| `google-github-actions/deploy-cloudrun` | `ssh` al servidor + `docker compose up -d --build` (o `docker stack deploy` si es Swarm) |
| Variables `PROJECT_ID` / `REGION` | `SSH_HOST` / `SSH_USER` / `DEPLOY_PATH` |

El escaneo de vulnerabilidades con Trivy se mantiene sin cambios, ya que es una herramienta de terceros y no depende del proveedor.

Un punto a resolver con el equipo de sistemas de la UCU es si el servidor tiene salida a internet para que un GitHub Actions hosteado en la nube pueda conectarse por SSH, o si hace falta un runner self-hosted.

### Almacenamiento de archivos

El flujo de subida de CVs y fotos de perfil está documentado en [Bucket Flow](./bucket-flow.md) y se encuentra implementado en el paquete `storage` del backend, que expone los endpoints de subida y borrado y genera signed URLs para la descarga de los CVs.

- Reemplazar la dependencia `spring-cloud-gcp-starter-storage` del `pom.xml` por el SDK de MinIO (`io.minio:minio`), si se opta por object storage compatible con S3. Si en cambio se opta por guardar los archivos directo en el filesystem del servidor, alcanza con `java.nio.file` y no hace falta SDK adicional.
- Reescribir `StorageServiceImpl`, que hoy trabaja con `Storage`, `BlobId` y `BlobInfo` del SDK de Google, para utilizar el cliente de MinIO (o `Files.write`/`Files.delete` si es filesystem). La lógica propia (validación de tipos de archivo, generación del nombre del objeto con UUID, manejo de errores por código HTTP) se mantiene igual.
- Las signed URLs V4 que genera `getSignedUrl` pasan a resolverse con URLs presignadas de MinIO (que también soporta expiración), o con un endpoint propio del backend que sirva el archivo autenticando la sesión, si se elige filesystem.
- Levantar el contenedor de MinIO en el `docker-compose.yml` de producción, con un volumen persistente en disco para los datos, o directamente crear un directorio en el servidor con los permisos adecuados para el filesystem.
- Reemplazar las propiedades `spring.cloud.gcp.storage.*` y `gcs.bucket-name` por la configuración equivalente (endpoint y bucket de MinIO, o el path del filesystem). El flag `GCP_STORAGE_ENABLED`, que hoy permite levantar el entorno local sin almacenamiento, conviene mantenerlo con el mismo propósito.
- La autenticación deja de resolverse con el JSON de la Service Account (`GOOGLE_APPLICATION_CREDENTIALS`) y pasa a un access key / secret key de MinIO guardados en el `.env` del servidor.
- Copiar los archivos existentes del bucket al servidor con `gsutil -m rsync` (bajada) y `mc mirror` (subida a MinIO) o `scp`/`rsync` si es filesystem plano. Como las columnas `profile_image` y `cv_file` guardan el nombre del objeto y no la URL completa, no hace falta migrar esas columnas.
- Definir una política de backup del volumen de archivos, ya que en GCP la durabilidad del bucket estaba garantizada por Google y ahora depende del disco del servidor (conviene un cron con `rsync` a un storage externo o al menos a otro disco).

### Base de datos

- Exportar los datos con `pg_dump` desde Cloud SQL y restaurarlos con `pg_restore` en el Postgres del servidor UCU. Al ser el mismo motor, la migración es de bajo riesgo.
- Confirmar qué versión de PostgreSQL se puede instalar o correr en contenedor en el servidor de la facultad, e igualarla a la actualmente usada en Cloud SQL para evitar incompatibilidades.
- Configurar el firewall del servidor (o las reglas de red interna de la UCU) para que solo el backend pueda acceder al postgres.
- A diferencia de Cloud SQL, acá no hay backups automáticos gestionados: hay que definir un cron propio con `pg_dump` periódico, y decidir dónde se guardan esas copias (otro disco, otro servidor de la facultad, o algún storage externo).
- Evaluar con el equipo de sistemas si hay un límite de recursos (CPU/RAM/disco) asignado al proyecto dentro del datacenter, ya que a diferencia de GCP no hay escalado automático ante un pico de uso.

## Plan de migración

La migración se realizaría por fases, validando primero en el ambiente de desarrollo.

1. Coordinar con el equipo de sistemas de la UCU la asignación del servidor (o VM dentro del datacenter), acceso SSH, IP o subdominio, y política de red (firewall, VPN, salida a internet).
2. Instalar Docker y Docker Compose en el servidor, y crear la estructura de carpetas para los ambientes DEV y PROD (o usar un único ambiente si la facultad no separa infraestructura).
3. Levantar en el servidor los contenedores de PostgreSQL, MinIO (o el directorio de filesystem) y Nginx/Traefik como reverse proxy.
4. Configurar el `.env` del servidor con los mismos secretos que existen hoy en Secret Manager.
5. Migrar los datos (`pg_dump`/`pg_restore`) y los archivos del bucket al servidor.
6. Aplicar los cambios de código y configuración descritos anteriormente.
7. Adaptar los workflows de CI/CD para desplegar por SSH y probarlos contra el ambiente de DEV en el servidor.
8. Realizar la validación end to end: login, flujos principales (vacantes, postulaciones, perfiles), subida y descarga de archivos, y envío de correos.
9. Definir la política de backups (base de datos y archivos) y, si aplica, monitoreo básico (uptime, uso de disco) ya que dejan de existir las alertas gestionadas de GCP.
10. Repetir el proceso para PROD, con una ventana de mantenimiento para el corte de datos.
11. Dar de baja los recursos de GCP una vez validado el ambiente productivo en el servidor de la UCU.

