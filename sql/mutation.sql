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
  AND owner_id = current_setting('jwt.claims.firebase_uid', TRUE)
RETURNING *
$$
    LANGUAGE SQL
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.delete_category(id integer) IS 'delete a category';
GRANT EXECUTE ON FUNCTION public.delete_category(integer) TO authuser;
