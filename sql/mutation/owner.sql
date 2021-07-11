CREATE OR REPLACE FUNCTION public.new_owner()
    RETURNS public.owner
AS
$$
DECLARE
    o   public.owner;
    uid text;
BEGIN
    SELECT current_setting('jwt.claims.firebase_uid', TRUE) INTO uid;

    INSERT INTO public.owner (id)
    VALUES (uid)
    RETURNING * INTO o;

    INSERT INTO public.category (name, owner_id, type)
    VALUES ('Food And Drink', uid, 'EXPENSE'),
           ('Transportation', uid, 'EXPENSE'),
           ('Shopping', uid, 'EXPENSE'),
           ('Bill', uid, 'EXPENSE'),
           ('Petrol', uid, 'EXPENSE'),
           ('Withdraw', uid, 'EXPENSE'),
           ('Doctor', uid, 'EXPENSE'),
           ('Game', uid, 'EXPENSE'),
           ('Salary', uid, 'INCOME'),
           ('Transfer', uid, 'TRANSFER'),
           ('Other', uid, 'ANY');

    INSERT INTO public.account (name, type, owner_id)
    VALUES ('Cash', 'CASH', uid),
           ('My Bank', 'BANK', uid);

    RETURN o;
END ;
$$
    LANGUAGE plpgsql
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.new_owner () IS E'@omit execute\nAdd a new owner from Firebase user';

CREATE OR REPLACE FUNCTION public.current_user()
    RETURNS public.owner
AS
$$
DECLARE
    o public.owner;
BEGIN
    SELECT *
    INTO o
    FROM public.owner
    WHERE id = current_setting('jwt.claims.firebase_uid', TRUE);
    IF o IS NULL THEN
        SELECT *
        INTO o
        FROM public.new_owner();
    END IF;
    RETURN o;
END;
$$
    LANGUAGE plpgsql
    STRICT
    SECURITY DEFINER;

COMMENT ON FUNCTION public.current_user() IS 'Get current logged-in user';
GRANT EXECUTE ON FUNCTION public.current_user() TO authuser;