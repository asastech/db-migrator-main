CREATE TYPE AccountStatus AS ENUM (
    'UNVERIFIED', 'VERIFIED', 'BANNED', 'DELETED'
);

CREATE TYPE AccountDeletedBy AS ENUM ('USER', 'SYSTEM', 'ADMIN');

CREATE TABLE "Account" (
    "id" UUID PRIMARY KEY, -- Keycloak Account ID
    "username" VARCHAR UNIQUE NOT NULL,
    "email" VARCHAR UNIQUE NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "status" AccountStatus NOT NULL DEFAULT 'UNVERIFIED',
    "deletedBy" AccountDeletedBy,
    "deletedById" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "deletedAt" TIMESTAMPTZ
);

CREATE TRIGGER Update_Account_Updated_At
BEFORE UPDATE ON "Account"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER Prevent_Account_Deletion
BEFORE DELETE ON "Account"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();
