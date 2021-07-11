CREATE OR REPLACE FUNCTION public.create_category(name text, type public.category_type)
    RETURNS public.category
AS
$$
INSERT INTO public.category (name, owner_id, type)
VALUES ($1, current_setting('jwt.claims.firebase_uid', TRUE, type))
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

CREATE OR REPLACE FUNCTION public.update_category(id integer, name text, type public.category_type)
    RETURNS public.category
AS
$$
UPDATE public.category c
SET c.name = $2, c.type = $3
WHERE c.id = $1
RETURNING *
$$
    LANGUAGE SQL  
    STRICT;

COMMENT ON FUNCTION public.update_category(id integer, name text, type public.category_type) 'update a category';
GRANT EXECUTE ON FUNCTION public.update_category(integer, text) TO authuser;