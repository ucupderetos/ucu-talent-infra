# Decisiones del proyecto

## Contexto

El proyecto se desarrolló en tres semanas, con un equipo que no había trabajado antes en infraestructura ni en DevOps.

Ese fue el criterio detrás de casi todas las decisiones: elegir herramientas que ya conocíamos o que fueran fáciles de aprender, para no gastar el tiempo que teníamos en capacitarnos.

---

## Infraestructura

- Cloud provider: Google Cloud Platform
- Base de datos: PostgreSQL 17
- Servicio de base de datos: Cloud SQL
- Backend: Cloud Run
- Frontend: Cloud Run
- Almacenamiento de archivos: Cloud Storage
- Gestión de secretos: Secret Manager
- Registro de imágenes: Artifact Registry
- Observabilidad: Cloud Monitoring
- CI/CD: GitHub Actions
- Flujo Git: Git Flow

---

## Por qué elegimos cada cosa

### Google Cloud Platform

Elegimos GCP porque es una plataforma amigable para meterse por primera vez en infraestructura. Como era nuestro primer contacto con DevOps, nos convenía trabajar con servicios administrados y una consola simple, que nos permitiera desplegar la aplicación sin tener que ocuparnos de administrar servidores.

### PostgreSQL

Es el motor con el que ya venía trabajando todo el equipo, tanto infra como desarrollo. Usar una base de datos que todos conocíamos nos evitó tener que aprender una tecnología nueva y bajó bastante el riesgo de errores durante el desarrollo.

### Git Flow

Es el flujo que usamos siempre y con el que estamos cómodos. Mantenerlo nos permitió empezar a trabajar desde el primer día, sin frenarnos a definir y aprender una estrategia de ramas distinta.

### GitHub Actions

Los repositorios del proyecto están en GitHub, así que usamos su propia herramienta de CI/CD. Al estar integrada, no tuvimos que configurar ni mantener un servicio aparte.

---

## Documentación relacionada

- [Git Workflow](./git-workflow.md)
- [Cloud SQL](./cloud-sql.md)
- [CI/CD Backend](./ci-cd-backend.md)
- [CI/CD Frontend](./ci-cd-frontend.md)
