# Secret Manager

## Objetivo

Google Cloud Secret Manager se utiliza para almacenar de forma segura las credenciales utilizadas por la infraestructura y la aplicación, evitando incluir información sensible en el código fuente, archivos de configuración o variables de entorno versionadas.

---

# Secretos utilizados

| Nombre | Descripción |
|---------|-------------|
| `dev-backend-db-username` | Usuario PostgreSQL utilizado por la aplicación Backend. |
| `dev-backend-db-password` | Contraseña del usuario utilizado por el Backend. |
| `dev-flyway-db-username` | Usuario PostgreSQL utilizado por Flyway para ejecutar migraciones. |
| `dev-flyway-db-password` | Contraseña del usuario utilizado por Flyway. |
| `dev-postgres-db-password` | Contraseña del usuario administrador `postgres`. |

---

# Configuración recomendada

Al crear un secreto utilizar la configuración por defecto.

- Replicación automática
- Encriptación administrada por Google
- Sin fecha de expiración
- Sin rotación automática
- Sin destrucción diferida

---

# Organización

Se utiliza la siguiente convención de nombres:

```

dev-backend-db-username
dev-backend-db-password

dev-flyway-db-username
dev-flyway-db-password

dev-postgres-db-password

```

Esta convención permite diferenciar fácilmente:

- entorno (`dev`)
- servicio (`backend`, `flyway`, `postgres`)
- tipo de credencial (`username`, `password`)

---

# Procedimiento para crear un secreto

1. Ingresar a Google Cloud Console.
2. Ir a Security → Secret Manager.
3. Tocar Create Secret.
4. Completar:

**Nombre**

Ejemplo:

```

dev-backend-db-password

```

**Valor secreto**

Ingresar el valor correspondiente.

5. Mantener la configuración por defecto.
6. Presionar Create Secret.

---


# Acceso

Los permisos sobre Secret Manager deben otorgarse únicamente a las cuentas de servicio o usuarios que realmente los necesiten.

Ejemplo:

- Backend → acceso a credenciales del Backend.
- Flyway → acceso a credenciales de Flyway.
- Infraestructura → acceso administrativo.
- El usuario `postgres` debe utilizarse únicamente para tareas administrativas.



