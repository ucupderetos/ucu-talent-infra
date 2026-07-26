CREATE ROLE backend_dev_role NOLOGIN;

CREATE USER backend_dev PASSWORD :'backend_password';

CREATE USER flyway_dev PASSWORD :'flyway_password';

GRANT backend_dev_role TO backend_dev;

GRANT CONNECT
ON DATABASE ucu_talent_database_dev
TO backend_dev_role, flyway_dev;

GRANT USAGE
ON SCHEMA public
TO backend_dev_role;

GRANT USAGE, CREATE
ON SCHEMA public
TO flyway_dev;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO backend_dev_role;

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA public
TO backend_dev_role;

-- Ejecutar conectado como flyway_dev
ALTER DEFAULT PRIVILEGES
FOR ROLE flyway_dev
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO backend_dev_role;

ALTER DEFAULT PRIVILEGES
FOR ROLE flyway_dev
IN SCHEMA public
GRANT USAGE, SELECT, UPDATE
ON SEQUENCES TO backend_dev_role;