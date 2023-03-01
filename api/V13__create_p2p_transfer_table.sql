CREATE TYPE P2pTransferStatus AS ENUM (
    'PENDING', 'COMPLETED', 'FAILED'
);

CREATE TYPE P2pTransferType AS ENUM (
    'PAYMENT', 'REFUND', 'REVERSAL'
);

CREATE TABLE IF NOT EXISTS "P2pTransfer" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "senderBankAccountId" UUID NOT NULL REFERENCES "BankAccount" ("id"),
    "receiverBankAccountId" UUID NOT NULL REFERENCES "BankAccount" ("id"),
    "amount" DECIMAL(10, 2) NOT NULL,
    "initiatedDate" TIMESTAMPTZ NOT NULL,
    "completedDate" TIMESTAMPTZ,
    "status" P2pTransferStatus NOT NULL,
    "reason" TEXT,
    "type" P2pTransferType NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER UPDATE_P2P_TRANSFER_UPDATED_AT
BEFORE UPDATE ON "P2pTransfer"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER PREVENT_P2P_TRANSFER_DELETION
BEFORE DELETE ON "P2pTransfer"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();

-- transfer money from one account to another if :-
-- the sender has enough money
-- the status of the inserted row is PENDING
-- the type is PAYMENT or REFUND or REVERSAL
-- the receiver and sender are not the same account
-- the amount is greater than 0:
CREATE OR REPLACE FUNCTION transfer_money() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'PENDING' AND (NEW.type = 'PAYMENT' OR NEW.type = 'REFUND' OR NEW.type = 'REVERSAL') AND NEW.senderBankAccountId != NEW.receiverBankAccountId AND NEW.amount > 0 THEN
        UPDATE "BankAccount" SET "balance" = "balance" - NEW.amount WHERE "id" = NEW.senderBankAccountId AND "balance" >= NEW.amount;
        IF FOUND THEN
            UPDATE "BankAccount" SET "balance" = "balance" + NEW.amount WHERE "id" = NEW.receiverBankAccountId;
            IF FOUND THEN
                NEW.status = 'COMPLETED';
                NEW.completedDate = NOW();
                RETURN NEW;
            ELSE
                NEW.status = 'FAILED';
                NEW.reason = 'Receiver bank account not found';
                RETURN NEW;
            END IF;
        ELSE
            NEW.status = 'FAILED';
            NEW.reason = 'Sender bank account not found or not enough money';
            RETURN NEW;
        END IF;
    ELSE
        NEW.status = 'FAILED';
        NEW.reason = 'Invalid status, type, sender and receiver bank accounts or amount';
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE PLPGSQL; -- noqa: L016

-- trigger to call the transfer_money() function
-- when a new row is inserted into the p2p_transfer table
CREATE TRIGGER P2P_TRANSFER_MONEY
AFTER INSERT ON "P2pTransfer"
FOR EACH ROW
EXECUTE PROCEDURE transfer_money();
