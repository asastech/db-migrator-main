CREATE TABLE "Notification" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "bankAccountId" UUID NOT NULL REFERENCES "BankAccount" ("id"),
    "message" TEXT NOT NULL,
    "details" JSONB,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_notification_updated_at
BEFORE UPDATE ON "Notification"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER prevent_notification_deletion
BEFORE DELETE ON "Notification"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();

-- function to create a notification whenever :-
-- a new api is created
-- a new transaction is created or has a status update
-- a new p2pTransfer is created or has a status update:
CREATE OR REPLACE FUNCTION create_notification() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF TG_TABLE_NAME = 'api' THEN
            INSERT INTO "Notification" ("bankAccountId", "message", "details")
            VALUES (NEW."bankAccountId", 'New API created', json_build_object('apiId', NEW."id"));
        ELSIF TG_TABLE_NAME = 'transaction' THEN
            INSERT INTO "Notification" ("bankAccountId", "message", "details")
            VALUES (NEW."bankAccountId", 'New transaction created', json_build_object('transactionId', NEW."id"));
        ELSIF TG_TABLE_NAME = 'p2p_transfer' THEN
            INSERT INTO "Notification" ("bankAccountId", "message", "details")
            VALUES (NEW."bankAccountId", 'New p2p transfer created', json_build_object('p2pTransferId', NEW."id"));
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF TG_TABLE_NAME = 'transaction' THEN
            IF OLD."status" != NEW."status" THEN
                INSERT INTO "Notification" ("bankAccountId", "message", "details")
                VALUES (NEW."bankAccountId", 'Transaction status updated', json_build_object('transactionId', NEW."id", 'oldStatus', OLD."status", 'newStatus', NEW."status"));
            END IF;
        ELSIF TG_TABLE_NAME = 'p2p_transfer' THEN
            IF OLD."status" != NEW."status" THEN
                INSERT INTO "Notification" ("bankAccountId", "message", "details")
                VALUES (NEW."bankAccountId", 'P2P transfer status updated', json_build_object('p2pTransferId', NEW."id", 'oldStatus', OLD."status", 'newStatus', NEW."status"));
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; -- noqa: L016

-- triggers to call the function whenever :-
-- a new api is created
-- a new transaction is created or has a status update
-- a new p2pTransfer is created or has a status update:
CREATE TRIGGER insert_notification_on_api_insert_or_update
AFTER INSERT OR UPDATE ON "Api"
FOR EACH ROW
EXECUTE PROCEDURE create_notification();

CREATE TRIGGER insert_notification_on_transaction_insert_or_update
AFTER INSERT OR UPDATE ON "Transaction"
FOR EACH ROW
EXECUTE PROCEDURE create_notification();

CREATE TRIGGER insert_notification_on_p2p_transfer_insert_or_update
AFTER INSERT OR UPDATE ON "P2pTransfer"
FOR EACH ROW
EXECUTE PROCEDURE create_notification();
