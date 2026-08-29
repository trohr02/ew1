/* 
=====================================================================
Procedure : bronze.sp_LoadInvoices
Target: bronze.invoices
=====================================================================   
Loads bronze.invoices from a Parquet file using OPENROWSET.

Example call:
EXEC bronze.sp_LoadInvoices
	@PipelineRunId = '12345678-aaaa-bbbb-cccc-1234567890ab',
	@ActivityName  = 'CopyInvoicesToBronze',
	@IngestedTs    = '2026-08-27T10:15:00.000000',
	@SourceFile    = '/Files/raw/invoices/invoices.parquet';  
===================================================================== */
CREATE     PROCEDURE bronze.sp_LoadInvoices
    @PipelineRunId VARCHAR(50),
    @ActivityName  VARCHAR(120),
    @IngestedTs    DATETIME2(6),
    @SourceFile    VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO bronze.invoices
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
        @PipelineRunId,
        @ActivityName,
        @IngestedTs,
        @SourceFile
    FROM OPENROWSET(
        BULK '/Files/raw/invoices/invoices.parquet',
        DATA_SOURCE = 'raw'
    )
    WITH
    (
        CompanyId       VARCHAR(4000),
        CustomerId      VARCHAR(4000),
        CountryId       VARCHAR(4000),
        DocumentNumber  VARCHAR(4000),
        DocumentType    VARCHAR(4000),
        PostingDate     VARCHAR(4000),
        Entry           VARCHAR(4000),
        EntryType       VARCHAR(4000),
        Amount          VARCHAR(4000)
    ) AS src;
END