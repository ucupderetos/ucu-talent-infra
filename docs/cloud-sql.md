# Cloud SQL

## Descripción

La aplicación utiliza **Google Cloud SQL** con **PostgreSQL** como motor de base de datos.

El acceso desde el backend se realiza mediante **Cloud SQL Auth Proxy**, dando una conexión autenticada y segura sin exponer directamente la instancia de Cloud SQL.

---

## Configuración de la instancia

| Configuración | Valor |
|---------------|-------|
| Proveedor | Google Cloud Platform |
| Servicio | Cloud SQL |
| Motor | PostgreSQL |
| Versión | PostgreSQL 17 |
| Región | us-central1 (Iowa) |
| Disponibilidad | Zona única |
| Tipo de máquina | Personalizada |
| CPU | 1 vCPU |
| Memoria | 3.75 GB |
| Almacenamiento | SSD 10 GB |
| Backups automáticos | Habilitados |
| Point-in-Time Recovery (PITR) | Habilitado |
| Método de conexión | Cloud SQL Auth Proxy |

---

## Organización de usuarios

La base de datos utiliza el principio de mínimos privilegios, separando los accesos según la responsabilidad de cada componente.

| Tipo de usuario | Propósito |
|-----------------|-----------|
| Administrador | Tareas administrativas de la instancia y mantenimiento. |
| Usuario de migraciones | Utilizado por Flyway para ejecutar las migraciones de la base de datos. |
| Usuario de aplicación | Utilizado por el backend durante la ejecución de la aplicación. |

---

## Roles

Los permisos se administran mediante roles de PostgreSQL.

| Rol | Descripción |
|------|-------------|
| Rol de aplicación | Permisos de lectura y escritura sobre las tablas utilizadas por la aplicación. |

Las modificaciones estructurales de la base de datos se realizan únicamente mediante migraciones de Flyway.

---

## Gestión de credenciales

Las credenciales de la base de datos no se almacenan en el repositorio.

Se gestionan mediante Google Cloud Secret Manager y son consumidas por los servicios durante la ejecución.

---

## Seguridad

- No se almacenan contraseñas en el código fuente.
- Se aplica el principio de mínimos privilegios mediante usuarios y roles específicos.
- Cada componente utiliza un usuario de base de datos con permisos específicos.
- La estructura de la base de datos se administra mediante Flyway.
- El acceso a la base de datos se realiza mediante Cloud SQL Auth Proxy.

---

## Documentación relacionada

- [Cloud SQL Auth Proxy](./cloud-sql-auth-proxy.md)
- [Secret Manager](./secret-manager.md)
