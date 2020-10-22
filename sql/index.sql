CREATE ROLE nologin;

CREATE ROLE authuser;

GRANT nologin TO postgraphile;
GRANT authuser TO postgraphile;

-- after schema creation and before function creation
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

GRANT USAGE ON SCHEMA public TO nologin, authuser;

CREATE TABLE IF NOT EXISTS owner
(
    id         text PRIMARY KEY,
    updated_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.owner TO nologin,authuser;
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

GRANT SELECT ON TABLE public.account TO nologin,authuser;
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

GRANT SELECT ON TABLE public.category TO nologin,authuser;
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
    category_id     integer          NOT NULL REFERENCES public.category ON DELETE CASCADE,
    from_account_id integer REFERENCES public.account ON DELETE CASCADE,
    to_account_id   integer REFERENCES public.account ON DELETE CASCADE,
    owner_id        text             NOT NULL REFERENCES public.owner ON DELETE CASCADE,
    occurred_at     timestamptz      NOT NULL DEFAULT now(),
    created_at      timestamptz      NOT NULL DEFAULT now(),
    updated_at      timestamptz      NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.transaction TO nologin,authuser;
COMMENT ON TABLE public.transaction IS E'@omit create,update,delete';
