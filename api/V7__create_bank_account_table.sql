CREATE TABLE IF NOT EXISTS "BankAccount" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "bankId" UUID NOT NULL REFERENCES "Bank" ("id"),
    "accountName" VARCHAR NOT NULL,
    "ssn" VARCHAR NOT NULL, -- Social Security Number
    "balance" NUMERIC(10, 2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "lastWithdrawal" TIMESTAMPTZ DEFAULT NULL,
    "lastDeposit" TIMESTAMPTZ DEFAULT NULL
);

CREATE TRIGGER update_bank_account_updated_at
BEFORE UPDATE ON "BankAccount"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER prevent_bank_account_deletion
BEFORE DELETE ON "BankAccount"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();

CREATE UNIQUE INDEX IF NOT EXISTS
"bank_account_account_name_ssn_bank_id_key"
ON "BankAccount" ("accountName", "ssn", "bankId");
