CREATE TABLE "CompanyDetails" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "accountId" UUID NOT NULL REFERENCES "Account" ("id"),
    "details" JSONB NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON "CompanyDetails" USING gin("details");

CREATE TRIGGER UPDATE_COMPANY_DETAILS_UPDATED_AT
BEFORE UPDATE ON "CompanyDetails"
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();
