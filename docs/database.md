# Base de datos

## Descripción

El proyecto utilizara una instancia de **PostgreSQL 17** alojada dentro de **Google Cloud SQL**.

Dentro de esta instancia se crearán 3 bases correspondientes, una para desarrollo, otra para QA y otra para producción.

## Bases de datos

| Ambiente | Base de datos |
|----------|---------------|
| dev | ucu-talent-database-dev |
| QA | ucu-talent-database_qa |
| prod | ucu-talent-database_prod |

## Usuarios

Cada base de datos contará con un usuario con los permisos correspondientes para poder acceder a la base de datos

> Las contraseñas no son almacenadas en el repositorio. Son gestionadas mediantes variables de entornos y secretos.