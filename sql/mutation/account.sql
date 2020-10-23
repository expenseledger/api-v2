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