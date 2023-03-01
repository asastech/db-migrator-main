CREATE TABLE IF NOT EXISTS "AccountApiConfig" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "apiId" UUID NOT NULL REFERENCES "Api" ("id") ON DELETE CASCADE,
    "accountId" UUID NOT NULL REFERENCES "Account" ("id") ON DELETE CASCADE,
    "isEnabled" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_account_api_config_updated_at
BEFORE UPDATE ON "AccountApiConfig"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- function to create api config for all accounts when a new api is created
CREATE OR REPLACE FUNCTION create_api_config_for_all_accounts()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AccountApiConfig" ("apiId", "accountId", "isEnabled")
    SELECT NEW.id, id, FALSE FROM "account";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_api_config_for_all_accounts
AFTER INSERT ON "Api"
FOR EACH ROW
EXECUTE PROCEDURE create_api_config_for_all_accounts();

-- function to create api config for all apis when a new account is created
CREATE OR REPLACE FUNCTION create_api_config_for_all_apis()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AccountApiConfig" ("apiId", "accountId", "isEnabled")
    SELECT id, NEW.id, FALSE FROM "Api";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_api_config_for_all_apis
AFTER INSERT ON "Account"
FOR EACH ROW
EXECUTE PROCEDURE create_api_config_for_all_apis();
