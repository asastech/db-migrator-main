CREATE TYPE ClientStatus AS ENUM (
    'CREATED', 'DISABLED', 'DELETED'
);

CREATE TYPE ClientDeletedBy AS ENUM ('USER', 'SYSTEM', 'ADMIN');

CREATE TYPE ClientType AS ENUM ('PUBLIC', 'CONFIDENTIAL');

CREATE TABLE "Client" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "applicationId" UUID NOT NULL REFERENCES "Application" ("id"),
    "name" UUID NOT NULL,
    "baseUrl" VARCHAR NOT NULL,
    "type" ClientType NOT NULL,
    "secret" TEXT NOT NULL,
    "status" ClientStatus NOT NULL DEFAULT 'CREATED',
    "deletedBy" ClientDeletedBy,
    "deletedById" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "deletedAt" TIMESTAMPTZ,
    UNIQUE("name", "secret")
);

CREATE TRIGGER Update_Client_Updated_At
BEFORE UPDATE ON "Client"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER Prevent_Client_Deletion
BEFORE DELETE ON "Client"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();
