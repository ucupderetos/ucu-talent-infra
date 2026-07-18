CREATE ROLE backend_qa_role NOLOGIN;

CREATE USER backend_qa PASSWORD :'backend_password';

CREATE USER flyway_qa PASSWORD :'flyway_password';

GRANT backend_qa_role TO backend_qa;

GRANT CONNECT
ON DATABASE ucu_talent_database_qa
TO backend_qa_role, flyway_qa;

GRANT USAGE
ON SCHEMA public
TO backend_qa_role;

GRANT USAGE, CREATE
ON SCHEMA public
TO flyway_qa;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO backend_qa_role;

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA public
TO backend_qa_role;

-- Permisos automáticos para objetos futuros creados por flyway_qa
ALTER DEFAULT PRIVILEGES
FOR ROLE flyway_qa
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO backend_qa_role;

ALTER DEFAULT PRIVILEGES
FOR ROLE flyway_qa
IN SCHEMA public
GRANT USAGE, SELECT, UPDATE
ON SEQUENCES TO backend_qa_role;