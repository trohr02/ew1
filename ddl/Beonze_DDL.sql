DROP TABLE IF EXISTS bronze.customers;
DROP TABLE IF EXISTS bronze.invoices;
DROP TABLE IF EXISTS bronze.payments;

CREATE TABLE bronze.customers (
    CustomerId       VARCHAR(4000) NULL,
    CustomerName     VARCHAR(4000) NULL,
    CustomerCategory VARCHAR(4000) NULL,
    PipelineRunId    VARCHAR(50) NOT NULL,
    ActivityName     VARCHAR(120) NOT NULL,
    IngestedTs       DATETIME2(6) NOT NULL,
    SourceFile       VARCHAR(1000) NOT NULL
);

CREATE TABLE bronze.invoices (
    CompanyId        VARCHAR(4000) NULL,
    CustomerId       VARCHAR(4000) NULL,
    CountryId        VARCHAR(4000) NULL,
    DocumentNumber    VARCHAR(4000) NULL,
    DocumentType      VARCHAR(4000) NULL,
    PostingDate      VARCHAR(4000) NULL,
    Entry            VARCHAR(4000) NULL,
    EntryType        VARCHAR(4000) NULL,
    Amount           VARCHAR(4000) NULL,
    PipelineRunId    VARCHAR(50) NOT NULL,
    ActivityName     VARCHAR(120) NOT NULL,
    IngestedTs       DATETIME2(6) NOT NULL,
    SourceFile       VARCHAR(1000) NOT NULL
);

CREATE TABLE bronze.payments (
    CompanyId        VARCHAR(4000) NULL,
    CustomerId       VARCHAR(4000) NULL,
    CountryId        VARCHAR(4000) NULL,
    DocumentNumber    VARCHAR(4000) NULL,
    DocumentType      VARCHAR(4000) NULL,
    PostingDate      VARCHAR(4000) NULL,
    Entry            VARCHAR(4000) NULL,
    EntryType        VARCHAR(4000) NULL,
    Amount           VARCHAR(4000) NULL,
    InvoiceNumber    VARCHAR(4000) NULL,
    InvoiceEntry     VARCHAR(4000) NULL,
    PipelineRunId    VARCHAR(50) NOT NULL,
    ActivityName     VARCHAR(120) NOT NULL,
    IngestedTs       DATETIME2(6) NOT NULL,
    SourceFile       VARCHAR(1000) NOT NULL
);



DROP TABLE IF EXISTS bronze.pipeline_run_info;

CREATE TABLE bronze.pipeline_run_info (
    PipelineRunId VARCHAR(50),
    PipelineName VARCHAR(120),
    PipelineId VARCHAR(50) ,
    PipelineStartTs DATETIME2(6),
    InsertedTs DATETIME2(6)
);

