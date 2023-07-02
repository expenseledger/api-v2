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

CREATE OR REPLACE FUNCTION public.transfer_v2(amount money, description text, category_id integer, from_account_id integer,
                                           to_account_id integer, occurred_at timestamptz)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    INSERT INTO public.transaction (amount, type, description, category_id, from_account_id, to_account_id, owner_id, occurred_at)
    VALUES ($1, 'TRANSFER', $2, $3, $4, $5, current_setting('jwt.claims.firebase_uid', TRUE), $6)
    RETURNING * INTO tx;

    UPDATE
        public.account
    SET balance = balance - $1
    WHERE id = $4;
    UPDATE
        public.account
    SET balance = balance + $1
    WHERE id = $5;

    RETURN tx;
END;
$$
    LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.transfer_v2(amount money, description text, category_id integer, from_account_id integer, to_account_id integer, occurred_at timestamptz) IS 'add transfer transaction';
GRANT EXECUTE ON FUNCTION public.transfer_v2(amount money, description text, category_id integer, from_account_id integer, to_account_id integer, occurred_at timestamptz) TO authuser;

CREATE OR REPLACE FUNCTION public.delete_transaction(id integer)
    RETURNS public.transaction
AS
$$
DECLARE
    tx public.transaction;
BEGIN
    DELETE FROM public.transaction AS t WHERE t.id = $1 and t.owner_id = current_setting('jwt.claims.firebase_uid', TRUE) RETURNING * INTO tx;

    IF tx.type = 'EXPENSE' OR tx.type = 'TRANSFER' THEN
        UPDATE public.account AS a SET balance = balance + tx.amount WHERE a.id = tx.from_account_id and a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
    END IF;
    IF tx.type = 'INCOME' OR tx.type = 'TRANSFER' THEN
        UPDATE PUBLIC.account AS a SET balance = balance - tx.amount WHERE a.id = tx.to_account_id and a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
    END IF;

    RETURN tx;
END;
$$ LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.delete_transaction(id integer) IS 'delete transaction';
GRANT EXECUTE ON FUNCTION public.delete_transaction(id integer) TO authuser;

CREATE OR REPLACE FUNCTION public.update_transaction(id integer, amount money, description text, category_id integer, occurred_at timestamptz)
    RETURNS public.transaction
AS
$$
DECLARE 
    old_tx public.transaction;
    tx public.transaction;
BEGIN
    SELECT * INTO old_tx
    FROM public.transaction AS t 
    WHERE t.id = $1
    AND t.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);

    UPDATE public.transaction AS t
    SET amount = $2
        , description = $3
        , category_id = $4
        , occurred_at = $5
    WHERE t.id = $1
    AND t.owner_id = current_setting('jwt.claims.firebase_uid', TRUE)
    RETURNING * INTO tx;

    IF old_tx.type = 'EXPENSE' OR old_tx.type = 'TRANSFER' THEN
        UPDATE public.account AS a SET balance = balance + old_tx.amount WHERE a.id = old_tx.from_account_id and a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
        UPDATE public.account AS a SET balance = balance - $2 WHERE a.id = old_tx.from_account_id and a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
    END IF;
    IF old_tx.type = 'INCOME' OR old_tx.type = 'TRANSFER' THEN
        UPDATE public.account AS a SET balance = balance - old_tx.amount WHERE a.id = old_tx.to_account_id and a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
        UPDATE public.account AS a SET balance = balance + $2 WHERE a.id = old_tx.to_account_id and a.owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
    END IF;

    RETURN tx;
END;
$$ LANGUAGE plpgsql
    STRICT;

COMMENT ON FUNCTION public.update_transaction(id integer, amount money, description text, category_id integer, occurred_at timestamptz) IS 'update transaction';
GRANT EXECUTE ON FUNCTION public.update_transaction(id integer, amount money, description text, category_id integer, occurred_at timestamptz) TO authuser;