CREATE TABLE IF NOT EXISTS "AccountApiUsage" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "apiId" UUID NOT NULL REFERENCES "Api" ("id") ON DELETE CASCADE,
    "accountId" UUID NOT NULL REFERENCES "Account" ("id") ON DELETE CASCADE,
    "month" DATE NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_account_api_usage_updated_at
BEFORE UPDATE ON "AccountApiUsage"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- this function is used to create api usage for all accounts
-- when a new api is created
CREATE OR REPLACE FUNCTION create_api_usage_for_all_accounts()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AccountApiUsage" ("apiId", "accountId", "month", "count")
    SELECT NEW.id, id, DATE_TRUNC('month', now()), 0 FROM "Account";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_api_usage_for_all_accounts
AFTER INSERT ON "Api"
FOR EACH ROW
EXECUTE PROCEDURE create_api_usage_for_all_accounts();

-- this function will be used to prevent api usage count from being decremented
-- below zero
CREATE OR REPLACE FUNCTION prevent_api_usage_count_below_zero()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.count < NEW.count) THEN
            RAISE EXCEPTION 'Cannot decrement API usage count below 0';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_api_usage_count_below_zero
BEFORE UPDATE ON "AccountApiUsage"
FOR EACH ROW
EXECUTE PROCEDURE prevent_api_usage_count_below_zero();

-- function to create api usage for all apis when a new account is created
CREATE OR REPLACE FUNCTION create_api_usage_for_all_apis()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AccountApiUsage" ("apiId", "accountId", "month", "count")
    SELECT id, NEW.id, DATE_TRUNC('month', now()), 0 FROM "Api";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_api_usage_for_all_apis
AFTER INSERT ON "Account"
FOR EACH ROW
EXECUTE PROCEDURE create_api_usage_for_all_apis();
