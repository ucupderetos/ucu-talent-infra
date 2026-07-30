# Migración de GCP a Azure

## Descripción

La infraestructura del proyecto fue implementada sobre **Google Cloud Platform (GCP)**. Sin embargo, la misma arquitectura puede ser desplegada en **Microsoft Azure** utilizando servicios equivalentes.

En este documento se describe el estado actual de la infraestructura en GCP, el servicio de Azure que cumple la misma función, los cambios que serían necesarios en el código y en los pipelines, y un plan de migración por fases.

---

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

---

## Mapeo de servicios

| Servicio en GCP | Servicio en Azure |
| --------------- | ----------------- |
| Cloud Run | Azure Container Apps |
| Artifact Registry | Azure Container Registry (ACR) |
| Cloud SQL for PostgreSQL | Azure Database for PostgreSQL - Flexible Server |
| Cloud Storage (bucket) | Azure Blob Storage (contenedor) |
| Secret Manager | Azure Key Vault |
| Service Account | Service Principal (Entra ID) u OIDC federado |
| Cloud SQL Auth Proxy | No aplica (conexión directa con SSL) |

Container Apps es el equivalente más directo a Cloud Run: es serverless, soporta scale-to-zero (no por defecto), permite definir mínimo y máximo de réplicas y expone tráfico HTTP.

Los nombres cambian pero la funcionalidad se mantiene: lo que en GCP es un bucket, en Azure es un contenedor dentro de una Storage Account, y las signed URLs pasan a llamarse SAS (Shared Access Signature).

---

## Cambios necesarios

### Backend

- Quitar la dependencia `com.google.cloud.sql:postgres-socket-factory` del `pom.xml` y utilizar el driver estándar de PostgreSQL con una URL JDBC directa (`jdbc:postgresql://<host>.postgres.database.azure.com:5432/<db>?sslmode=require`).
- Actualizar `spring.datasource.url` en `application.properties` para apuntar al host de Azure. El usuario y la contraseña se siguen inyectando por variables de entorno.
- Eliminar del `docker-compose.yml` el servicio `cloud-sql-proxy` y las variables asociadas. El entorno local se conecta directo al Postgres del propio compose.
- Flyway no requiere cambios, ya que es agnóstico del proveedor cloud y las migraciones aplican igual sobre PostgreSQL en Azure.
- La variable `PORT` sigue funcionando sin cambios, porque Container Apps también inyecta el puerto al contenedor.

### Frontend

- No tiene dependencias de SDKs de GCP, por lo que la migración es puramente de infraestructura y el Dockerfile no requiere cambios.
- El único cambio es el valor de `NEXT_PUBLIC_API_BASE_URL`, que debe apuntar a la nueva URL del backend en Azure. Como se resuelve en tiempo de build, hay que reconstruir la imagen del frontend y no solamente volver a desplegarla.

### CI/CD

Los workflows de GitHub Actions de ambos repositorios requieren los siguientes reemplazos:

| Actualmente | En Azure |
| ----------- | -------- |
| `google-github-actions/auth` | `azure/login` |
| `google-github-actions/setup-gcloud` + push a Artifact Registry | `docker/login-action` contra ACR + `docker push` |
| `google-github-actions/deploy-cloudrun` | `azure/container-apps-deploy-action` o `az containerapp update` |
| Variables `PROJECT_ID` / `REGION` | `AZURE_RESOURCE_GROUP` / `AZURE_LOCATION` / `ACR_NAME` / `CONTAINER_APP_NAME` |

El escaneo de vulnerabilidades con Trivy se mantiene sin cambios, ya que es una herramienta de terceros y no depende del proveedor cloud.

### Almacenamiento de archivos

El flujo de subida de CVs y fotos de perfil está documentado en [Bucket Flow](./bucket-flow.md) y se encuentra implementado en el paquete `storage` del backend, que expone los endpoints de subida y borrado y genera signed URLs para la descarga de los CVs.

- Reemplazar la dependencia `spring-cloud-gcp-starter-storage` del `pom.xml` por `spring-cloud-azure-starter-storage-blob`.
- Reescribir `StorageServiceImpl`, que hoy trabaja con `Storage`, `BlobId` y `BlobInfo` del SDK de Google, para utilizar `BlobContainerClient` y `BlobClient` del SDK de Azure. La lógica propia (validación de tipos de archivo, generación del nombre del objeto con UUID, manejo de errores por código HTTP) se mantiene igual.
- Las signed URLs V4 que genera `getSignedUrl` pasan a resolverse con SAS (Shared Access Signature), que también permite definir un tiempo de expiración.
- Crear una Storage Account con un contenedor por ambiente, en lugar del bucket actual.
- Reemplazar las propiedades `spring.cloud.gcp.storage.*` y `gcs.bucket-name` por la configuración equivalente de Azure. El flag `GCP_STORAGE_ENABLED`, que hoy permite levantar el entorno local sin almacenamiento, conviene mantenerlo con el mismo propósito.
- La autenticación deja de resolverse con el JSON de la Service Account (`GOOGLE_APPLICATION_CREDENTIALS`) y pasa a Managed Identity o a una connection string almacenada en Key Vault. 
- Copiar los archivos existentes del bucket al contenedor de Azure con `azcopy`. Como las columnas `profile_image` y `cv_file` guardan el nombre del objeto y no la URL completa.

### Base de datos

- Exportar los datos con `pg_dump` desde Cloud SQL y restaurarlos con `pg_restore` en Azure. Al ser el mismo motor, la migración es de bajo riesgo.
- Confirmar que la versión de PostgreSQL disponible en Flexible Server sea compatible con la utilizada actualmente.
- Configurar las reglas de firewall o la integración con VNet, equivalente a las IP autorizadas de Cloud SQL.

---

## Plan de migración

La migración se realizaría por fases, validando primero en el ambiente de desarrollo.

1. Crear en Azure el Resource Group, el ACR, la instancia de PostgreSQL, la Storage Account, el Key Vault y los dos Container Apps del ambiente DEV.
2. Cargar en Key Vault los mismos secretos que existen hoy en Secret Manager.
3. Migrar los datos y los archivos de DEV, validando con `flyway info` que el historial de migraciones coincida.
4. Aplicar los cambios de código y configuración descritos anteriormente.
5. Adaptar los workflows de CI/CD y probarlos contra DEV.
6. Realizar la validación end to end en DEV: login, flujos principales (vacantes, postulaciones, perfiles), subida y descarga de archivos, y envío de correos.
7. Repetir el proceso para PROD, con una ventana de mantenimiento para el corte de datos.
8. Dar de baja los recursos de GCP una vez validado el ambiente productivo en Azure.

---

## Documentación relacionada

- [Cloud SQL](./cloud-sql.md)
- [Bucket Flow](./bucket-flow.md)
- [Secret Manager](./secret-manager.md)
- [CI/CD Backend](./ci-cd-backend.md)
- [CI/CD Frontend](./ci-cd-frontend.md)
- [Monitoring en otros entornos](./monitoring-implementation-alternatives.md)
