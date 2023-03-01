CREATE TYPE ApiVisibility AS ENUM (
    'PUBLIC', 'PRIVATE'
);

CREATE TABLE IF NOT EXISTS "Api" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR NOT NULL,
    "description" TEXT NOT NULL,
    "version" VARCHAR NOT NULL,
    "context" VARCHAR NOT NULL,
    "visibility" VARCHAR NOT NULL DEFAULT 'PUBLIC',
    "isEnabled" BOOLEAN NOT NULL DEFAULT FALSE,
    "isProtected" BOOLEAN NOT NULL DEFAULT FALSE,
    "subscriptionRequired" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TRIGGER Update_Api_Updated_At
BEFORE UPDATE ON "Api"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();
