CREATE TYPE ApplicationStatus AS ENUM ('ACTIVE', 'INACTIVE', 'DELETED');

CREATE TYPE ApplicationDeletedBy AS ENUM ('USER', 'SYSTEM', 'ADMIN');

CREATE TABLE "Application" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "accountId" UUID NOT NULL REFERENCES "Account" ("id"),
    "name" VARCHAR NOT NULL,
    "status" ApplicationStatus NOT NULL DEFAULT 'ACTIVE',
    "deletedBy" ApplicationDeletedBy,
    "deletedById" UUID,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "deletedAt" TIMESTAMPTZ,
    UNIQUE("accountId", "name")
);

CREATE TRIGGER Update_Application_Updated_At
BEFORE UPDATE ON "Application"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER Prevent_Application_Deletion
BEFORE DELETE ON "Application"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();
