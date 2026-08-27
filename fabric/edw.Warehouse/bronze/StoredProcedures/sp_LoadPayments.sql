/* ============================================================================
   Procedure : bronze.sp_LoadPayments
   Target:     bronze.payments
   ============================================================================   
   Loads bronze.payments from  CSV file using OPENROWSET

   Example call:
   EXEC bronze.sp_LoadPayments
        @PipelineRunId = 'a1b2c3d4-0000-1111-2222-333344445555',
        @ActivityName  = 'CopyPaymentsToBronze',
        @IngestedTs    = '2026-08-27T10:15:00.000000',
        @SourceFile    = '/Files/raw/payments/payments.csv';   
   ============================================================================ */
CREATE   PROCEDURE bronze.sp_LoadPayments
    @PipelineRunId  VARCHAR(50),
    @ActivityName   VARCHAR(120),
    @IngestedTs     DATETIME2(6),
    @SourceFile     VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO bronze.payments
    (
        CompanyId,
        CustomerId,
        CountryId,
        DocumentNumber,
        DocumentType,
        PostingDate,
        Entry,
        EntryType,
        Amount,
        InvoiceNumber,
        InvoiceEntry,
        PipelineRunId,
        ActivityName,
        IngestedTs,
        SourceFile
    )
    SELECT
        src.CompanyId,
        src.CustomerId,
        src.CountryId,
        src.DocumentNumber,
        src.DocumentType,
        src.PostingDate,
        src.Entry,
        src.EntryType,
        src.Amount,
        src.InvoiceNumber,
        src.InvoiceEntry,
        @PipelineRunId,
        @ActivityName,
        @IngestedTs,
        @SourceFile
    FROM OPENROWSET(
        BULK '/Files/raw/payments/payments.csv',
        DATA_SOURCE = 'raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        FIELDTERMINATOR = ';',
        HEADER_ROW = TRUE
    )
    WITH (
        CompanyId       VARCHAR(4000),
        CustomerId      VARCHAR(4000),
        CountryId       VARCHAR(4000),
        DocumentNumber  VARCHAR(4000),
        DocumentType    VARCHAR(4000),
        PostingDate     VARCHAR(4000),
        Entry           VARCHAR(4000),
        EntryType       VARCHAR(4000),
        Amount          VARCHAR(4000),
        InvoiceNumber   VARCHAR(4000),
        InvoiceEntry    VARCHAR(4000)
    ) AS src;
END