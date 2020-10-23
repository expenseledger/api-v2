CREATE OR REPLACE FUNCTION public.new_owner()
    RETURNS public.owner
AS
$$
INSERT INTO public.owner (id)
VALUES (current_setting('jwt.claims.firebase_uid', TRUE))
RETURNING *
$$
    LANGUAGE SQL
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.new_owner () IS E'@omit execute\nAdd a new owner from Firebase user';

CREATE OR REPLACE FUNCTION public.current_user()
    RETURNS public.owner
AS
$$
DECLARE
    o public.owner;
BEGIN
    SELECT *
    INTO o
    FROM public.owner
    WHERE id = current_setting('jwt.claims.firebase_uid', TRUE);
    IF o IS NULL THEN
        SELECT *
        INTO o
        FROM public.new_owner();
    END IF;
    RETURN o;
END;
$$
    LANGUAGE plpgsql
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.current_user() IS 'Get current logged-in user';
GRANT EXECUTE ON FUNCTION public.current_user() TO authuser;

CREATE OR REPLACE FUNCTION public.create_category(name text)
    RETURNS public.category
AS
$$
INSERT INTO public.category (name, owner_id)
VALUES ($1, current_setting('jwt.claims.firebase_uid', TRUE))
RETURNING *
$$
    LANGUAGE SQL
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.create_category(name text) IS 'create a new category to be used in transactions';
GRANT EXECUTE ON FUNCTION public.create_category(NAME text) TO authuser;

CREATE OR REPLACE FUNCTION public.delete_category(id integer)
    RETURNS public.category
AS
$$
DELETE
FROM public.category AS c
WHERE c.id = $1
RETURNING *
$$
    LANGUAGE SQL
    STRICT;

COMMENT ON FUNCTION public.delete_category(id integer) IS 'delete a category';
GRANT EXECUTE ON FUNCTION public.delete_category(integer) TO authuser;

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

CREATE OR REPLACE FUNCTION public.spend(amount money, description text, category_id integer, from_account_id integer)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    INSERT INTO public.transaction (amount, type, description, category_id, from_account_id, owner_id)
    VALUES ($1, 'EXPENSE', $2, $3, $4, current_setting('jwt.claims.firebase_uid', TRUE))
    RETURNING * INTO tx;

    UPDATE
        public.account
    SET balance = balance - $1
    WHERE id = $4;

    RETURN tx;
END;
$$
    LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.spend(amount money, description text, category_id integer, from_account_id integer) IS 'add expense transaction';
GRANT EXECUTE ON FUNCTION public.spend(amount money, description text, category_id integer, from_account_id integer) TO authuser;
