INSERT INTO "Api" (
    "name",
    "description",
    "version",
    "context",
    "visibility",
    "isEnabled",
    "isProtected",
    "subscriptionRequired"
)
VALUES (
    'Account Information Service API',
    'This API gives access to bank accounts information',
    '1.0.0',
    '/accounts',
    'PRIVATE',
    TRUE,
    TRUE,
    TRUE
),
(
    'Payment Initiation Service API',
    'This API gives access to bank payments initiation',
    '1.0.0',
    '/payments',
    'PRIVATE',
    FALSE,
    TRUE,
    TRUE
);
