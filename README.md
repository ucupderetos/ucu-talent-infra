# UCU Talent — Infraestructura
 
Documentación central de la infraestructura del proyecto **UCU Talent**, un portal laboral que conecta empresas, alumnos y egresados de la Universidad Católica del Uruguay.
 
Este repositorio reúne las decisiones de arquitectura, el pipeline de CI/CD, la configuración de base de datos, el manejo de secretos, la observabilidad de la infraestructura y el plan de portabilidad hacia otro proveedor cloud.
 
---
 
## Arquitectura general
 
El proyecto está desplegado íntegramente en **Google Cloud Platform (GCP)**, con una arquitectura monolítica (decisión tomada explícitamente por restricciones de tiempo). Consta de dos servicios en contenedores, una base de datos relacional y un bucket para almacenamiento de archivos.
 
| Componente | Servicio en GCP |
|---|---|
| Backend (API, Java + Maven) | Cloud Run (`api-dev` / `api-prod`) |
| Frontend (Next.js) | Cloud Run (`web-dev` / `web-prod`) |
| Registro de imágenes Docker | Artifact Registry |
| Base de datos | Cloud SQL for PostgreSQL 17 |
| Almacenamiento de archivos (CVs, fotos de perfil) | Cloud Storage |
| Gestión de secretos | Secret Manager |
| Autenticación del CI/CD | Service Account key (`GCP_SA_KEY`) |
| CI/CD | GitHub Actions |
| Infraestructura como código | Terraform |
| Configuración | Ansible |
| Flujo de versionado | Git Flow |
 
La autenticación de la aplicación es propia (JWT con cookie httpOnly), no depende de un servicio de identidad externo.
 
---
 
## Índice de documentación
 
### Flujo de trabajo
 
| Documento | Descripción |
|---|---|
| [Git Workflow](./git-workflow.md) | Estrategia de ramas (Git Flow), nomenclatura y reglas de contribución del equipo. |
 
### CI/CD
 
| Documento | Descripción |
|---|---|
| [CI/CD Backend](./ci-cd-backend.md) | Pipeline de GitHub Actions para el backend Java + Maven: test, build check, escaneo con Trivy y deploy a Cloud Run (`api-dev` / `api-prod`). |
| [CI/CD Frontend](./ci-cd-frontend.md) | Pipelines de GitHub Actions para el frontend Next.js: workflows separados por ambiente, build con `NEXT_PUBLIC_API_BASE_URL`, escaneo con Trivy y deploy a Cloud Run (`web-dev` / `web-prod`). |
 
### Base de datos
 
| Documento | Descripción |
|---|---|
| [Cloud SQL](./cloud-sql.md) | Configuración de la instancia PostgreSQL, organización de usuarios y roles bajo el principio de mínimos privilegios. |
| [Cloud SQL Auth Proxy](./cloud-sql-auth-proxy.md) | Cómo conectarse a la base de datos desde un cliente PostgreSQL (DataGrip, DBeaver, pgAdmin, etc.) usando el proxy. |
| [Setup del entorno local](./cloud-sql-local-setup.md) | Guía paso a paso para instalar Google Cloud SDK, autenticarse y levantar el backend localmente contra Cloud SQL. |
 
### Almacenamiento de archivos
 
| Documento | Descripción |
|---|---|
| [Bucket Flow](./bucket-flow.md) | Flujo de subida de CVs y fotos de perfil: el backend sube el archivo al bucket vía SDK de Google Cloud y obtiene una signed URL con tiempo de expiración, usando la Service Account por defecto de la instancia de Cloud Run. Funcionalidad exclusiva de los entornos desplegados, no disponible en local por motivos de seguridad. |
 
### Seguridad y secretos
 
| Documento | Descripción |
|---|---|
| [Secret Manager](./secret-manager.md) | Convención de nombres, listado de secretos por entorno (DEV/PROD) y procedimiento para crear nuevos secretos. |
 
### Observabilidad
 
| Documento | Descripción |
|---|---|
| [Monitoring](./monitoring.md) | Estrategia de observabilidad: Cloud Logging, Cloud Monitoring, dashboards por ambiente y políticas de alerta configuradas. |
| [Guía de uso de Monitoring](./monitoring-user-guide.md) | Guía práctica para navegar Cloud Monitoring, revisar dashboards, alertas, logs y Error Reporting ante un incidente. |
| [Alternativas de implementación](./monitoring-implementation-alternatives.md) | Cómo replicar la misma estrategia de observabilidad en Azure (Azure Monitor, Log Analytics, Application Insights) o en un Data Center on-premises (Prometheus, Grafana, ELK). |
 
### Costos
 
| Documento | Descripción |
|---|---|
| [Billing](./billing.md) | Desglose de costos mensuales por servicio. Cloud SQL representa el mayor porcentaje del gasto de infraestructura. |
 
### Decisiones y portabilidad
 
| Documento | Descripción |
|---|---|
| [Decisiones del proyecto](./desicions.md) | Resumen de las decisiones de infraestructura tomadas: proveedor, base de datos, IaC, configuración, CI/CD y flujo de Git. |
| [Migración GCP → Azure](./gcp-to-azure-migration.md) | Mapeo de servicios equivalentes, cambios necesarios en backend/frontend/CI-CD y plan de migración por fases. |
 
---
 
## Resumen de costos
 
| Servicio | Costo mensual (USD) |
|---|---|
| Cloud SQL | $52.44 |
| Cloud Run | $1.32 |
| Cloud DNS | $0.23 |
| Artifact Registry | $0.07 |
| **Total** | **$54.06** |
 
> Los valores pueden variar por créditos promocionales o beneficios del Free Tier. Ver [billing.md](./billing.md) para el detalle completo.
 
---
 
## Ambientes
 
El proyecto opera con dos ambientes completamente separados, tanto en GitHub (Environments) como en GCP:
 
| | Desarrollo | Producción |
|---|---|---|
| Rama | `dev` | `main` |
| Backend | `api-dev` | `api-prod` |
| Frontend | `web-dev` | `web-prod` |
| Base de datos | `ucu_talent_database_dev` | `ucu_talent_database_prod` |
| GitHub Environment | `development` | `production` |
 
---
 
## Flujo de contribución (resumen)
 
Este proyecto sigue **Git Flow**. Reglas principales:
 
- Todas las ramas se crean desde `dev`, excepto `hotfix/*` que se crea desde `main`.
- No se permite push directo a `main` ni a `dev`.
- Todo cambio pasa por Pull Request con al menos una aprobación.
Ver el detalle completo, incluyendo la nomenclatura de ramas (`feature/`, `bugfix/`, `hotfix/`, `release/`, `refactor/`, `chore/`, `docs/`), en [Git Workflow](./git-workflow.md).
 
---
 
## Portabilidad a otros proveedores
 
Si bien la infraestructura actual está desplegada en GCP, la arquitectura fue diseñada para ser portable. La documentación incluye planes concretos de migración de infraestructura y de observabilidad hacia:
 
- **Microsoft Azure** — ver [Migración GCP → Azure](./gcp-to-azure-migration.md) y [Monitoring en Azure](./monitoring-implementation-alternatives.md).
- **Data Center on-premises** — ver la sección correspondiente en [Alternativas de implementación de Monitoring](./monitoring-implementation-alternatives.md).