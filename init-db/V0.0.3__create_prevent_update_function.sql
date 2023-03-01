CREATE OR REPLACE FUNCTION prevent_operation ()
RETURNS TRIGGER
AS $$
BEGIN
  RAISE EXCEPTION 'operation is not allowed';
END;
$$
LANGUAGE plpgsql;

