CREATE ROLE nologin;

CREATE ROLE authuser;

GRANT nologin TO postgraphile;
GRANT authuser TO postgraphile;

-- after schema creation and before function creation
ALTER DEFAULT privileges REVOKE EXECUTE ON functions FROM public;

GRANT usage ON SCHEMA public TO nologin, authuser;

CREATE TABLE IF NOT EXISTS owner
(
    id         text PRIMARY KEY,
    updated_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now()
);

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
    owner_id   text         NOT NULL REFERENCES public.owner (id) ON DELETE CASCADE,
    created_at timestamptz  NOT NULL DEFAULT now(),
    updated_at timestamptz  NOT NULL DEFAULT now(),
    UNIQUE (name, owner_id)
);

CREATE TABLE IF NOT EXISTS category
(
    id         serial PRIMARY KEY,
    name       text        NOT NULL,
    owner_id   text        NOT NULL REFERENCES public.owner (id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (name, owner_id)
);

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
    category_id     integer          NOT NULL REFERENCES public.category (id) ON DELETE CASCADE,
    from_account_id integer REFERENCES public.account (id) ON DELETE CASCADE,
    to_account_id   integer REFERENCES public.account (id) ON DELETE CASCADE,
    owner_id        text             NOT NULL REFERENCES public.owner (id) ON DELETE CASCADE,
    occurred_at     timestamptz      NOT NULL DEFAULT now(),
    created_at      timestamptz      NOT NULL DEFAULT now(),
    updated_at      timestamptz      NOT NULL DEFAULT now()
);
