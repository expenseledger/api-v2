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

CREATE OR REPLACE FUNCTION public.receive(amount money, description text, category_id integer, to_account_id integer)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    INSERT INTO public.transaction (amount, type, description, category_id, to_account_id, owner_id)
    VALUES ($1, 'INCOME', $2, $3, $4, current_setting('jwt.claims.firebase_uid', TRUE))
    RETURNING * INTO tx;

    UPDATE
        public.account
    SET balance = balance + $1
    WHERE id = $4;

    RETURN tx;
END;
$$
    LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.receive(amount money, description text, category_id integer, to_account_id integer) IS 'add income transaction';
GRANT EXECUTE ON FUNCTION public.receive(amount money, description text, category_id integer, to_account_id integer) TO authuser;