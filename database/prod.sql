CREATE ROLE backend_prod_role NOLOGIN;

CREATE USER backend_prod PASSWORD :'backend_password';

CREATE USER flyway_prod PASSWORD :'flyway_password';

GRANT backend_prod_role TO backend_prod;

GRANT CONNECT
ON DATABASE ucu_talent_database_prod
TO backend_prod_role, flyway_prod;

GRANT USAGE
ON SCHEMA public
TO backend_prod_role;

GRANT USAGE, CREATE
ON SCHEMA public
TO flyway_prod;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO backend_prod_role;

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA public
TO backend_prod_role;

-- Ejecutar conectado como usuario flyway_prod
ALTER DEFAULT PRIVILEGES
FOR ROLE flyway_prod
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO backend_prod_role;

ALTER DEFAULT PRIVILEGES
FOR ROLE flyway_prod
IN SCHEMA public
GRANT USAGE, SELECT, UPDATE
ON SEQUENCES TO backend_prod_role;