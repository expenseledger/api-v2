CREATE ROLE nologin;

CREATE ROLE authuser;

GRANT nologin TO postgraphile;
GRANT authuser TO postgraphile;

-- after schema creation and before function creation
ALTER DEFAULT privileges REVOKE EXECUTE ON functions FROM public;

GRANT usage ON SCHEMA public TO nologin, authuser;
