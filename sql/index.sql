CREATE ROLE nologin;
CREATE ROLE authuser;

GRANT nologin TO postgraphile;
GRANT authuser TO postgraphile;

-- after schema creation and before function creation
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

GRANT USAGE ON SCHEMA public TO nologin, authuser;

CREATE EXTENSION IF NOT EXISTS moddatetime;

CREATE TABLE IF NOT EXISTS owner
(
    id         text PRIMARY KEY,
    updated_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER mdt_owner
    BEFORE UPDATE
    ON public.owner
    FOR EACH ROW
EXECUTE PROCEDURE moddatetime(updated_at);

ALTER TABLE public.owner
    ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE public.owner TO authuser;
CREATE POLICY owner_only ON public.owner TO authuser
    USING (id = current_setting('jwt.claims.firebase_uid', TRUE));
COMMENT ON TABLE public.owner IS E'@omit create,update,delete';

CREATE TYPE public.account_type AS enum (
    'CASH',
    'BANK',
    'CREDIT'
    );

CREATE TABLE IF NOT EXISTS account
(
    id         serial PRIMARY KEY,
    name       text         NOT NULL,
    type       account_type NOT NULL,
    balance    money        NOT NULL DEFAULT 0,
    owner_id   text         NOT NULL REFERENCES public.owner ON DELETE CASCADE,
    created_at timestamptz  NOT NULL DEFAULT now(),
    updated_at timestamptz  NOT NULL DEFAULT now(),
    UNIQUE (name, owner_id)
);

CREATE TRIGGER mdt_account
    BEFORE UPDATE
    ON public.account
    FOR EACH ROW
EXECUTE PROCEDURE moddatetime(updated_at);

ALTER TABLE public.account
    ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE, DELETE ON TABLE public.account TO authuser;
CREATE POLICY owner_only ON public.account TO authuser
    USING (owner_id = current_setting('jwt.claims.firebase_uid', TRUE));
COMMENT ON TABLE public.account IS E'@omit create,update,delete';

CREATE TABLE IF NOT EXISTS category
(
    id         serial PRIMARY KEY,
    name       text        NOT NULL,
    owner_id   text        NOT NULL REFERENCES public.owner ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (name, owner_id)
);

CREATE TRIGGER mdt_category
    BEFORE UPDATE
    ON public.category
    FOR EACH ROW
EXECUTE PROCEDURE moddatetime(updated_at);

ALTER TABLE public.category
    ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE, DELETE ON TABLE public.category TO authuser;
CREATE POLICY owner_only ON public.category TO authuser
    USING (owner_id = current_setting('jwt.claims.firebase_uid', TRUE));
COMMENT ON TABLE public.category IS E'@omit create,update,delete';

CREATE TYPE public.transaction_type AS enum (
    'EXPENSE',
    'INCOME',
    'TRANSFER'
    );

CREATE TABLE IF NOT EXISTS transaction
(
    id              serial PRIMARY KEY,
    amount          money            NOT NULL,
    type            transaction_type NOT NULL,
    description     text             NOT NULL DEFAULT '',
    category_id     integer REFERENCES public.category ON DELETE CASCADE,
    from_account_id integer REFERENCES public.account ON DELETE CASCADE,
    to_account_id   integer REFERENCES public.account ON DELETE CASCADE,
    owner_id        text             NOT NULL REFERENCES public.owner ON DELETE CASCADE,
    occurred_at     timestamptz      NOT NULL DEFAULT now(),
    created_at      timestamptz      NOT NULL DEFAULT now(),
    updated_at      timestamptz      NOT NULL DEFAULT now()
);

CREATE TRIGGER mdt_transaction
    BEFORE UPDATE
    ON public.transaction
    FOR EACH ROW
EXECUTE PROCEDURE moddatetime(updated_at);

ALTER TABLE public.transaction
    ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.transaction TO authuser;
GRANT ALL ON SEQUENCE public.transaction_id_seq TO authuser;
CREATE POLICY owner_only ON public.transaction TO authuser
    USING (owner_id = current_setting('jwt.claims.firebase_uid', TRUE))
    WITH CHECK (
            category_id IN (SELECT id
                            FROM public.category) AND
            (from_account_id IN (SELECT id
                                 FROM public.account) OR
             to_account_id IN (SELECT id
                               FROM public.account))
    );
COMMENT ON TABLE public.transaction IS E'@omit create,update,delete';
COMMENT ON COLUMN public.transaction.occurred_at IS E'@name date';

CREATE FUNCTION "transaction_fromAccount"(tx public.transaction)
    RETURNS public.account AS
$$
SELECT *
FROM public.account
WHERE id = tx.from_account_id;
$$ LANGUAGE sql STABLE;
GRANT EXECUTE ON FUNCTION public."transaction_fromAccount"(tx public.transaction) TO authuser;

CREATE FUNCTION "transaction_toAccount"(tx public.transaction)
    RETURNS public.account AS
$$
SELECT *
FROM public.account
WHERE id = tx.to_account_id;
$$ LANGUAGE sql STABLE;
GRANT EXECUTE ON FUNCTION public."transaction_toAccount"(tx public.transaction) TO authuser;