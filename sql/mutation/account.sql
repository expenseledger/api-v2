CREATE OR REPLACE FUNCTION public.create_account(name text, type public.account_type, balance money)
    RETURNS public.account
AS
$$
INSERT INTO public.account (name, type, balance, owner_id)
VALUES ($1, $2, $3, current_setting('jwt.claims.firebase_uid', TRUE))
RETURNING *
$$
    LANGUAGE SQL
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.create_account(name text, type public.account_type, balance money) IS 'create a new account';
GRANT EXECUTE ON FUNCTION public.create_account(NAME text, TYPE public.account_type, balance money) TO authuser;

CREATE OR REPLACE FUNCTION public.close_account(id integer)
    RETURNS public.account
AS
$$
DELETE
FROM public.account AS a
WHERE a.id = $1
RETURNING *
$$
    LANGUAGE SQL
    STRICT;

COMMENT ON FUNCTION public.close_account(id integer) IS 'close account';
GRANT EXECUTE ON FUNCTION public.close_account(id integer) TO authuser;

CREATE OR REPLACE FUNCTION public.close_account_v2(id integer)
    RETURNS public.account
AS
$$
DELETE
FROM public.account AS a
WHERE a.id = $1
AND a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE)
RETURNING *
$$
    LANGUAGE SQL
    STRICT;

COMMENT ON FUNCTION public.close_account_v2(id integer) IS 'close account';
GRANT EXECUTE ON FUNCTION public.close_account_v2(id integer) TO authuser;

CREATE OR REPLACE FUNCTION public.update_account(id integer, name text, type public.account_type)
    RETURNS public.account
AS
$$
UPDATE public.account
SET name = $2, type = $3
WHERE id = $1
RETURNING *
$$
    LANGUAGE SQL
    STRICT;

COMMENT ON FUNCTION public.update_account(id integer, name text, type public.account_type) IS 'update account'
GRANT EXECUTE ON FUNCTION public.update_account(id integer, name text, type public.account_type) TO authuser;

CREATE OR REPLACE FUNCTION public.update_account_v2(id integer, name text, type public.account_type)
    RETURNS public.account
AS
$$
UPDATE public.account
SET name = $2, 
    type = $3
WHERE id = $1
AND owner_id = current_setting('jwt.claims.firebase_uid', TRUE)

RETURNING *
$$
    LANGUAGE SQL
    STRICT;

COMMENT ON FUNCTION public.update_accoun_v2(id integer, name text, type public.account_type) IS 'update account'
GRANT EXECUTE ON FUNCTION public.update_account_v2(id integer, name text, type public.account_type) TO authuser;