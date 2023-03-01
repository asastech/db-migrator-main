CREATE TYPE TransactionStatus AS ENUM ('PENDING', 'SUCCESS', 'FAILED');

CREATE TABLE IF NOT EXISTS "Transaction" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "bankAccountId" UUID NOT NULL REFERENCES "BankAccount" ("id"),
    "amount" NUMERIC(10, 2) NOT NULL DEFAULT 0,
    "isWithdrawal" BOOLEAN NOT NULL DEFAULT FALSE,
    "isDeposit" BOOLEAN NOT NULL DEFAULT FALSE,
    "status" TransactionStatus NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER Update_Transaction_Updated_At
BEFORE UPDATE ON "Transaction"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER Prevent_Transaction_Deletion
BEFORE DELETE ON "Transaction"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();

CREATE OR REPLACE FUNCTION update_bank_account_balance_and_transaction_status() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.isWithdrawal = TRUE) THEN
            IF (NEW.amount > (SELECT "balance" FROM "BankAccount" WHERE "id" = NEW.bankAccountId)) THEN
                UPDATE "Transaction" SET "status" = 'FAILED' WHERE "id" = NEW.id;
                RETURN NULL;
            END IF;
            UPDATE "BankAccount" SET "balance" = "balance" - NEW.amount, "lastWithdrawalDate" = NEW.createdAt WHERE "id" = NEW.bankAccountId;
        ELSIF (NEW.isDeposit = TRUE) THEN
            UPDATE "BankAccount" SET "balance" = "balance" + NEW.amount, "lastDepositDate" = NEW.createdAt WHERE "id" = NEW.bankAccountId;
        END IF;
        UPDATE "Transaction" SET "status" = 'SUCCESS' WHERE "id" = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE Plpgsql; -- noqa: L016

CREATE TRIGGER Update_Bank_Account_Balance_And_Transaction_Status
AFTER INSERT ON "Transaction"
FOR EACH ROW
EXECUTE PROCEDURE update_bank_account_balance_and_transaction_status();
