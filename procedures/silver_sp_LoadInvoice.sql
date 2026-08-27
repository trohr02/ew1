CREATE OR ALTER PROCEDURE silver.sp_LoadInvoice AS
BEGIN
    DECLARE @CurrentPipelineRunId VARCHAR(50);

    SELECT TOP (1) @CurrentPipelineRunId = PipelineRunId
    FROM bronze.pipeline_run_info
    ORDER BY InsertedTs DESC
    ;

	INSERT INTO silver.invoice_bad
    (CompanyId, InvoiceNumber, PostingDate, Amount, RejectReason, PipelineRunId, InsertedTs)
	SELECT 
	   CompanyId, 
	   DocumentNumber,
	   PostingDate,
	   Amount,
	   CASE
		   WHEN TRIM(ISNULL(CompanyId,''))     = '' THEN 'Missing CompanyId'
		   WHEN TRIM(ISNULL(DocumentNumber,'')) = '' THEN 'Missing DocumentNumber'
		   WHEN TRY_CAST(PostingDate AS DATE)  IS NULL THEN 'Invalid PostingDate'
		   WHEN TRY_CAST(Amount AS DECIMAL(18,8)) IS NULL THEN 'Invalid Amount'
	   END,
	   @CurrentPipelineRunId,
	   GETUTCDATE()
	FROM bronze.invoices
	WHERE PipelineRunId = @CurrentPipelineRunId
	AND
	(TRIM(ISNULL(CompanyId,'')) = ''
	   OR TRIM(ISNULL(DocumentNumber,'')) = ''
	   OR TRY_CAST(PostingDate AS DATE) IS NULL
	   OR TRY_CAST(Amount AS DECIMAL(18,8)) IS NULL
	)
    ;

    MERGE silver.invoice AS t
    USING (
        SELECT
            CAST(TRIM(CompanyId)                      AS VARCHAR(10)) AS CompanyId,
            CAST(COALESCE(TRIM(CustomerId),'XNA')     AS VARCHAR(20)) AS CustomerId,
            CAST(UPPER(TRIM(CountryId)) AS CHAR(2))   AS CountryId,
            CAST(TRIM(DocumentNumber) AS VARCHAR(50)) AS InvoiceNumber,
            CAST(COALESCE(TRIM(DocumentType),'XNA')   AS VARCHAR(20)) AS InvoiceType,
            TRY_CAST(PostingDate     AS DATE)         AS PostingDate,
            CAST(TRIM(Entry)         AS VARCHAR(20))  AS Entry,
            CAST(TRIM(EntryType)     AS VARCHAR(20))  AS EntryType,
            TRY_CAST(Amount AS DECIMAL(18,8))         AS Amount
        FROM bronze.invoices i
        WHERE PipelineRunId = @CurrentPipelineRunId
        AND TRIM(ISNULL(CompanyId,'')) <> ''
        AND TRIM(ISNULL(DocumentNumber,'')) <> ''
        AND TRY_CAST(PostingDate AS DATE) IS NOT NULL
        AND TRY_CAST(Amount AS DECIMAL(18,8)) IS NOT NULL
    ) AS s
    ON  t.CompanyId     = s.CompanyId
    AND t.InvoiceNumber = s.InvoiceNumber
    WHEN MATCHED AND (
        t.InvoiceType <> s.InvoiceType OR
        t.PostingDate <> s.PostingDate OR
        t.CustomerId  <> s.CustomerId OR
        t.CountryId   <> s.CountryId OR
        t.Entry       <> s.Entry OR 
        t.EntryType   <> s.EntryType OR
        t.Amount      <> s.Amount)
	THEN UPDATE SET
        t.InvoiceType = s.InvoiceType, 
        t.PostingDate = s.PostingDate,
        t.CustomerId  = s.CustomerId,  
        t.CountryId   = s.CountryId,
        t.Entry       = s.Entry,       
        t.EntryType   = s.EntryType,
        t.Amount      = s.Amount,  
	    t.DeletedFlag = 0,
        t.UpdatedTs  = GETUTCDATE(),
        t.UpdatedRunId = @CurrentPipelineRunId
    WHEN NOT MATCHED THEN INSERT (
        CompanyId, InvoiceNumber, InvoiceType, PostingDate, CustomerId,
        CountryId, Entry, EntryType, Amount, DeletedFlag,
        InsertedTs, UpdatedTs, InsertedRunId, UpdatedRunId
        ) VALUES (
		s.CompanyId, s.InvoiceNumber, s.InvoiceType, s.PostingDate, s.CustomerId, 
        s.CountryId, s.Entry, s.EntryType, s.Amount, 0,
        GETUTCDATE(), GETUTCDATE(), @CurrentPipelineRunId, @CurrentPipelineRunId
		)
    WHEN NOT MATCHED BY SOURCE THEN UPDATE SET 
        t.DeletedFlag = 1,
        t.UpdatedRunId = @CurrentPipelineRunId
    ;

END;
GO