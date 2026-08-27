CREATE OR ALTER PROCEDURE silver.sp_LoadPayment AS
BEGIN
    DECLARE @CurrentPipelineRunId VARCHAR(50);

    SELECT TOP (1) @CurrentPipelineRunId = PipelineRunId
    FROM bronze.pipeline_run_info
    ORDER BY InsertedTs DESC
    ;
	
    INSERT INTO silver.payment_quarantine
    SELECT CompanyId, PaymentNumber, PostingDate, Amount,
           CASE
               WHEN TRIM(ISNULL(CompanyId,''))     = '' THEN 'Missing CompanyId'
               WHEN TRIM(ISNULL(PaymentNumber,'')) = '' THEN 'Missing PaymentNumber'
               WHEN TRY_CAST(PostingDate AS DATE)  IS NULL THEN 'Invalid PostingDate'
               WHEN TRY_CAST(Amount AS DECIMAL(18,8)) IS NULL THEN 'Invalid Amount'
           END,
           GETUTCDATE()
    FROM bronze.payment
    WHERE TRIM(ISNULL(CompanyId,''))     = ''
       OR TRIM(ISNULL(PaymentNumber,'')) = ''
       OR TRY_CAST(PostingDate AS DATE)  IS NULL
       OR (Amount IS NOT NULL AND TRY_CAST(Amount AS DECIMAL(18,8)) IS NULL)
	;

    WITH ranked AS (
        SELECT *, ROW_NUMBER() OVER (
                    PARTITION BY TRIM(CompanyId), TRIM(PaymentNumber)
                    ORDER BY _ingest_ts DESC) AS rn
        FROM bronze.payment
        WHERE TRIM(ISNULL(CompanyId,''))     <> ''
          AND TRIM(ISNULL(PaymentNumber,'')) <> ''
          AND TRY_CAST(PostingDate AS DATE)  IS NOT NULL
          AND TRY_CAST(Amount AS DECIMAL(18,8)) IS NOT NULL
    )
    MERGE silver.payment AS t
    USING (
        SELECT
            CAST(TRIM(CompanyId) AS VARCHAR(10))                      AS CompanyId,
            CAST(TRIM(DocumentNumber) AS VARCHAR(50))                 AS PaymentNumber,
            CAST(COALESCE(TRIM(DocumentType), 'XNA') AS VARCHAR(20))  AS PaymentType,
            CAST(COALESCE(TRIM(CustomerId), 'XNA') AS VARCHAR(20))    AS CustomerId,
            CAST(COALESCE(UPPER(TRIM(CountryId)), 'XX') AS CHAR(2))   AS CountryId,
            TRY_CAST(PostingDate  AS DATE)                            AS PostingDate,
            CAST(TRIM(Entry)  AS VARCHAR(20))                         AS Entry,
            CAST(NULLIF(TRIM(EntryType),'') AS VARCHAR(20))           AS EntryType,
            TRY_CAST(Amount AS DECIMAL(18,8))                         AS Amount,
            CAST(COALESCE(TRIM(InvoiceNumber), 'XNA') AS VARCHAR(50)) AS InvoiceNumber,
            CAST(COALESCE(TRIM(InvoiceEntry), 'XNA')  AS VARCHAR(20)) AS InvoiceEntry
        FROM bronze.payments
		WHERE PipelineRunId = @CurrentPipelineRunId
		AND TRIM(ISNULL(CompanyId,'')) <> ''
        AND TRIM(ISNULL(DocumentNumber,'')) <> ''
        AND TRY_CAST(PostingDate AS DATE) IS NOT NULL
        AND TRY_CAST(Amount AS DECIMAL(18,8)) IS NOT NULL
    ) AS s
    ON  t.CompanyId     = s.CompanyId
    AND t.PaymentNumber = s.PaymentNumber
    WHEN MATCHED AND (
	    t.PaymentType   <> s.PaymentType OR
		t.CustomerId    <> s.CustomerId OR
        t.CountryId     <> s.CountryId OR
		t.PostingDate   <> s.PostingDate OR
        t.Entry         <> s.Entry OR
		t.EntryType     <> s.EntryType OR
        t.Amount        <> s.Amount OR
		t.InvoiceNumber <> s.InvoiceNumber OR
        t.InvoiceEntry  <> s.InvoiceEntry)
	THEN UPDATE SET
        t.PaymentType   = s.PaymentType,
		t.CustomerId    = s.CustomerId,
        t.CountryId     = s.CountryId, 
		t.PostingDate   = s.PostingDate,
        t.Entry         = s.Entry,       
		t.EntryType     = s.EntryType,
        t.Amount        = s.Amount,      
		t.InvoiceNumber = s.InvoiceNumber,
        t.InvoiceEntry  = s.InvoiceEntry,
	    t.DeletedFlag = 0,
        t.UpdatedTs  = GETUTCDATE(),
        t.UpdatedRunId = @CurrentPipelineRunId
    WHEN NOT MATCHED THEN INSERT (
        CompanyId, PaymentNumber, PaymentType, CustomerId, CountryId,
        PostingDate, Entry, EntryType, Amount, InvoiceNumber, InvoiceEntry,
        DeletedFlag, InsertedTs, UpdatedTs, InsertedRunId, UpdatedRunId
        ) VALUES (
		s.CompanyId, s.PaymentNumber, s.PaymentType, s.CustomerId, s.CountryId,
		s.PostingDate, s.Entry, s.EntryType, s.Amount, s.InvoiceNumber, s.InvoiceEntry, 
		0, GETUTCDATE(), GETUTCDATE(), @CurrentPipelineRunId, @CurrentPipelineRunId
		)
    WHEN NOT MATCHED BY SOURCE THEN UPDATE SET 
        t.DeletedFlag = 1,
        t.UpdatedRunId = @CurrentPipelineRunId
    ;
END
GO
