-- =====================================================================
-- Silver layer DDL — Fabric Warehouse
-- Notes: Fabric DW has no DEFAULT constraints; PK/FK must be added by
--        ALTER TABLE (not inline) and must be NONCLUSTERED NOT ENFORCED.
-- =====================================================================

EXEC sp_executesql N'CREATE SCHEMA silver';

DROP TABLE IF EXISTS silver.payment;
DROP TABLE IF EXISTS silver.invoice;
DROP TABLE IF EXISTS silver.customer;


-- ---------------------------------------------------------------------
-- customer
-- ---------------------------------------------------------------------
CREATE TABLE silver.customer (
    CustomerId        VARCHAR(20)  NOT NULL,
    CustomerName      VARCHAR(120) NOT NULL,
    CustomerCategory  VARCHAR(40)  NOT NULL,
    DeletedFlag       CHAR(1)      NOT NULL,
    InsertedTs        DATETIME2(6) NOT NULL,
    UpdatedTs         DATETIME2(6) NULL,
    InsertedRunId     VARCHAR(50)  NOT NULL,
    UpdatedRunId      VARCHAR(50)  NULL
);

-- ---------------------------------------------------------------------
-- invoice
-- ---------------------------------------------------------------------
CREATE TABLE silver.invoice (
    CompanyId         VARCHAR(10)     NOT NULL,
    InvoiceNumber     VARCHAR(50)     NOT NULL,
    InvoiceType       VARCHAR(20)     NOT NULL,
    PostingDate       DATE            NOT NULL,
    CustomerId        VARCHAR(20)     NOT NULL,
    CountryId         CHAR(2)         NOT NULL,
    Entry             VARCHAR(20)     NULL,
    EntryType         VARCHAR(20)     NULL,
    Amount            DECIMAL(18,8)   NULL,
    DeletedFlag       INT             NOT NULL,
    InsertedTs        DATETIME2(6)    NOT NULL,
    UpdatedTs         DATETIME2(6) NULL,
    InsertedRunId     VARCHAR(50)  NOT NULL,
    UpdatedRunId      VARCHAR(50)  NULL
);

-- ---------------------------------------------------------------------
-- payment
-- ---------------------------------------------------------------------
CREATE TABLE silver.payment (
    CompanyId         VARCHAR(10)     NOT NULL,
    PaymentNumber     VARCHAR(50)     NOT NULL,
    PaymentType       VARCHAR(20)     NOT NULL,
    CustomerId        VARCHAR(20)     NOT NULL,
    CountryId         CHAR(2)         NOT NULL,
    PostingDate       DATE            NOT NULL,
    Entry             VARCHAR(20)     NULL,
    EntryType         VARCHAR(20)     NULL,
    Amount            DECIMAL(18,8)   NULL,
    InvoiceNumber     VARCHAR(50)     NOT NULL,
    InvoiceEntry      VARCHAR(20)     NOT NULL,
    DeletedFlag       INT             NOT NULL,
    InsertedTs        DATETIME2(6)    NOT NULL,
    UpdatedTs         DATETIME2(6) NULL,
    InsertedRunId     VARCHAR(50)  NOT NULL,
    UpdatedRunId      VARCHAR(50)  NULL
);

-- =====================================================================
-- Constraints (metadata only — the engine uses them for optimisation,
-- it does NOT enforce them)
-- =====================================================================

ALTER TABLE silver.customer
    ADD CONSTRAINT PK_silver_customer
    PRIMARY KEY NONCLUSTERED (CustomerId) NOT ENFORCED;

ALTER TABLE silver.invoice
    ADD CONSTRAINT PK_silver_invoice
    PRIMARY KEY NONCLUSTERED (CompanyId, InvoiceNumber) NOT ENFORCED;

ALTER TABLE silver.payment
    ADD CONSTRAINT PK_silver_payment
    PRIMARY KEY NONCLUSTERED (CompanyId, PaymentNumber) NOT ENFORCED;

ALTER TABLE silver.invoice
    ADD CONSTRAINT FK_silver_invoice_customer
    FOREIGN KEY (CustomerId) REFERENCES silver.customer (CustomerId) NOT ENFORCED;

ALTER TABLE silver.payment
    ADD CONSTRAINT FK_silver_payment_customer
    FOREIGN KEY (CustomerId) REFERENCES silver.customer (CustomerId) NOT ENFORCED;

ALTER TABLE silver.payment
    ADD CONSTRAINT FK_silver_payment_invoice
    FOREIGN KEY (CompanyId, InvoiceNumber)
    REFERENCES silver.invoice (CompanyId, InvoiceNumber) NOT ENFORCED;



DROP TABLE IF EXISTS silver.invoice_bad; 
CREATE TABLE silver.invoice_bad (
    CompanyId VARCHAR(4000), 
    InvoiceNumber VARCHAR(4000),
    PostingDate VARCHAR(4000), 
    Amount VARCHAR(4000),
    RejectReason VARCHAR(500),
    PipelineRunId VARCHAR(50),
    InsertedTs DATETIME2(6)
);

DROP TABLE IF EXISTS silver.payment_bad;
CREATE TABLE silver.payment_bad (
    CompanyId VARCHAR(4000),
    PaymentNumber VARCHAR(4000),
    PostingDate VARCHAR(4000), 
    Amount VARCHAR(4000),
    RejectReason VARCHAR(500),
    PipelineRunId VARCHAR(50),
    InsertedTs DATETIME2(6)
);
