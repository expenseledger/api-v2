CREATE OR REPLACE FUNCTION "transaction_fromAccount"(tx public.transaction)
    RETURNS public.account AS
$$
SELECT *
FROM public.account
WHERE id = tx.from_account_id
AND owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
$$ LANGUAGE sql STABLE;
GRANT EXECUTE ON FUNCTION public."transaction_fromAccount"(tx public.transaction) TO authuser;

CREATE OR REPLACE FUNCTION "transaction_toAccount"(tx public.transaction)
    RETURNS public.account AS
$$
SELECT *
FROM public.account
WHERE id = tx.to_account_id
AND owner_id = current_setting('jwt.claims.firebase_uid', TRUE);
$$ LANGUAGE sql STABLE;
GRANT EXECUTE ON FUNCTION public."transaction_toAccount"(tx public.transaction) TO authuser;

CREATE OR REPLACE FUNCTION "transaction_month_year_list_by_account_id"(account_id int)
    RETURNS SETOF text AS
$$
SELECT DISTINCT TO_CHAR(tx.occurred_at , 'YYYY-MM') AS month_year
FROM public.transaction tx
WHERE (tx.to_account_id = account_id OR tx.from_account_id = account_id)
AND tx.owner_id = current_setting('jwt.claims.firebase_uid', TRUE)
ORDER BY month_year DESC;
$$ LANGUAGE sql STABLE;
GRANT EXECUTE ON FUNCTION public."transaction_month_year_list_by_account_id"(account_id int) TO authuser;

