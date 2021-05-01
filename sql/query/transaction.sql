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
