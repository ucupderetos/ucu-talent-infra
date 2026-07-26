# Database Setup

Esta carpeta contiene los scripts SQL utilizados para configurar los usuarios, roles y permisos de las bases de datos de cada entorno del proyecto.

## Estructura

```
database/
├── dev.sql
├── prod.sql
└── README.md
```

## Scripts

| Archivo | Entorno |
|---------|----------|
| `dev.sql` | Desarrollo |
| `prod.sql` | Producción |

Cada script configura:

- Rol del backend (`backend_<env>_role`).
- Usuario del backend (`backend_<env>`).
- Usuario de Flyway (`flyway_<env>`).
- Permisos sobre la base de datos.
- Permisos sobre el esquema `public`.
- Permisos sobre tablas y secuencias existentes.
- Permisos automáticos para objetos creados por Flyway (`ALTER DEFAULT PRIVILEGES`).

## Contraseñas

Los scripts utilizan variables para las contraseñas de los usuarios.

- `backend_password`
- `flyway_password`

## Usuarios de desarrolladores

Los usuarios individuales de los desarrolladores no forman parte de estos scripts. Su creación y asignación al rol correspondiente (`backend_<env>_role`) es responsabilidad del equipo de Infra.

## Requisitos

- PostgreSQL.
- Permisos de administrador para crear usuarios, roles y otorgar permisos.