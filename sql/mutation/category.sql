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

CREATE OR REPLACE FUNCTION public.create_category_v2(name text, type public.category_type)
    RETURNS public.category
AS
$$
INSERT INTO public.category (name, owner_id, type)
VALUES ($1, current_setting('jwt.claims.firebase_uid', TRUE), $2)
RETURNING *
$$
    LANGUAGE SQL
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.create_category_v2(name text, type public.category_type) IS 'create a new category to be used in transactions v2';
GRANT EXECUTE ON FUNCTION public.create_category_v2(NAME text, type public.category_type) TO authuser;

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

CREATE OR REPLACE FUNCTION public.update_category(id integer, name text, type public.category_type)
    RETURNS public.category
AS
$$
UPDATE public.category
SET name = $2, type = $3
WHERE id = $1
RETURNING *
$$
    LANGUAGE SQL  
    STRICT;

COMMENT ON FUNCTION public.update_category(id integer, name text, type public.category_type) IS 'update a category';
GRANT EXECUTE ON FUNCTION public.update_category(integer, text, type public.category_type) TO authuser;