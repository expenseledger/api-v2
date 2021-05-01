CREATE OR REPLACE FUNCTION public.spend(amount money, description text, category_id integer, from_account_id integer, occurred_at timestamptz)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    INSERT INTO public.transaction (amount, type, description, category_id, from_account_id, owner_id, occurred_at)
    VALUES ($1, 'EXPENSE', $2, $3, $4, current_setting('jwt.claims.firebase_uid', TRUE), $5)
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

COMMENT ON FUNCTION public.spend(amount money, description text, category_id integer, from_account_id integer, occurred_at timestamptz) IS 'add expense transaction';
GRANT EXECUTE ON FUNCTION public.spend(amount money, description text, category_id integer, from_account_id integer, occurred_at timestamptz) TO authuser;

CREATE OR REPLACE FUNCTION public.receive(amount money, description text, category_id integer, to_account_id integer, occurred_at timestamptz)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    INSERT INTO public.transaction (amount, type, description, category_id, to_account_id, owner_id, occurred_at)
    VALUES ($1, 'INCOME', $2, $3, $4, current_setting('jwt.claims.firebase_uid', TRUE), $5)
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

COMMENT ON FUNCTION public.receive(amount money, description text, category_id integer, to_account_id integer, occurred_at timestamptz) IS 'add income transaction';
GRANT EXECUTE ON FUNCTION public.receive(amount money, description text, category_id integer, to_account_id integer, occurred_at timestamptz) TO authuser;

CREATE OR REPLACE FUNCTION public.transfer(amount money, description text, from_account_id integer,
                                           to_account_id integer, occurred_at timestamptz)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    INSERT INTO public.transaction (amount, type, description, from_account_id, to_account_id, owner_id, occurred_at)
    VALUES ($1, 'TRANSFER', $2, $3, $4, current_setting('jwt.claims.firebase_uid', TRUE), $5)
    RETURNING * INTO tx;

    UPDATE
        public.account
    SET balance = balance - $1
    WHERE id = $3;
    UPDATE
        public.account
    SET balance = balance + $1
    WHERE id = $4;

    RETURN tx;
END;
$$
    LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.transfer(amount money, description text, from_account_id integer, to_account_id integer, occurred_at timestamptz) IS 'add transfer transaction';
GRANT EXECUTE ON FUNCTION public.transfer(amount money, description text, from_account_id integer, to_account_id integer, occurred_at timestamptz) TO authuser;

CREATE OR REPLACE FUNCTION public.delete_transaction(id integer)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    DELETE FROM public.transaction AS t WHERE t.id = $1 RETURNING * INTO tx;

    IF tx.type = 'EXPENSE' OR tx.type = 'TRANSFER' THEN
        UPDATE public.account SET balance = balance + tx.amount WHERE id = tx.from_account_id;
    END IF;
    IF tx.type = 'INCOME' OR tx.type = 'TRANSFER' THEN
        UPDATE PUBLIC.account SET balance = balance - tx.amount WHERE id = tx.to_account_id;
    END IF;

    RETURN tx;
END;
$$ LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.delete_transaction(id integer) IS 'add transfer transaction';
GRANT EXECUTE ON FUNCTION public.delete_transaction(id integer) TO authuser;
