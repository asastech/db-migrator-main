CREATE TYPE CertificateStatus AS ENUM (
    'ISSUED', 'REVOKED', 'EXPIRED', 'DELETED'
);

CREATE TYPE CertificateDeletedBy AS ENUM ('USER', 'SYSTEM', 'ADMIN');

CREATE TABLE "Certificate" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "accountId" UUID NOT NULL REFERENCES "Account" ("id"),
    "description" TEXT NOT NULL,
    "commonName" VARCHAR NOT NULL,
    "serialNumber" VARCHAR NOT NULL,
    "status" CertificateStatus NOT NULL DEFAULT 'ISSUED',
    "deletedBy" CertificateDeletedBy,
    "deletedById" UUID,
    "expiresAt" TIMESTAMPTZ NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "deletedAt" TIMESTAMPTZ,
    UNIQUE("accountId", "commonName")
);

CREATE TRIGGER Update_Certificate_Updated_At
BEFORE UPDATE ON "Certificate"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER Prevent_Certificate_Deletion
BEFORE DELETE ON "Certificate"
FOR EACH ROW
EXECUTE PROCEDURE prevent_operation();
