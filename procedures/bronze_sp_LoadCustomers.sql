/* ============================================================
   Procedure : bronze.sp_LoadCustomers
   Target:     bronze.customers
   ============================================================
   Load bronze.customers from file using OPENROWSET

   Example call:

   EXEC bronze.usp_LoadCustomers
        @PipelineRunId = '12345678-aaaa-bbbb-cccc-1234567890ab',
        @ActivityName  = 'CopyInvoicesToBronze',
        @IngestedTs    = '2026-08-27T10:15:00.000000',
        @SourceFile    = '/Files/raw/invoices/invoices.parquet';
   ============================================================ */
CREATE OR ALTER   PROCEDURE bronze.sp_LoadCustomers
    @PipelineRunId VARCHAR(50),
    @ActivityName  VARCHAR(120),
    @IngestedTs    DATETIME2(6),
    @SourceFile    VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO bronze.customers
    (
        CustomerId,
        CustomerName,
        CustomerCategory,
        PipelineRunId,
        ActivityName,
        IngestedTs,
        SourceFile
    )
    SELECT
        src.CustomerId,
        src.CustomerName,
        src.CustomerCategory,
        @PipelineRunId,
        @ActivityName,
        @IngestedTs,
        @SourceFile
    FROM OPENROWSET(
        BULK 'Files/raw/customers/customers.txt',
        DATA_SOURCE = 'raw',
        FORMAT = 'CSV',
        FIELDTERMINATOR = '\t',
        HEADER_ROW = TRUE
    ) AS src;
END;
