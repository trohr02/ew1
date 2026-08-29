/* 
============================================================================
Procedure : silver.sp_LoadPayment
Target:     silver.payment
============================================================================   
Loads bronze.payments from bronze.payment
Method: Merg, soft delete 
Bad data inserted into silver.payment_bad
============================================================================
*/
CREATE   PROCEDURE silver.sp_LoadPayment
    @PipelineRunId VARCHAR(50)
AS
BEGIN
    DECLARE @BronzePipelineRunId VARCHAR(50);

    SELECT TOP (1) @BronzePipelineRunId = PipelineRunId
    FROM bronze.pipeline_run_info
	WHERE PipelineName = 'Pipeline_Bronze'	
    ORDER BY InsertedTs DESC
    ;
	
    INSERT INTO silver.payment_bad
    SELECT CompanyId, DocumentNumber, PostingDate, Amount,
           CASE
               WHEN TRIM(ISNULL(CompanyId,''))     = '' THEN 'Missing CompanyId'
               WHEN TRIM(ISNULL(DocumentNumber,'')) = '' THEN 'Missing DocumentNumber'
               WHEN TRIM(ISNULL(InvoiceNumber,'')) = '' THEN 'Missing InvoiceNumber'
               WHEN TRY_CONVERT(DATE, PostingDate, 104) IS NULL THEN 'Invalid PostingDate'
               WHEN TRY_CAST(Amount AS DECIMAL(18,8)) IS NULL THEN 'Invalid Amount'
           END,
		   @BronzePipelineRunId,
           GETUTCDATE()
    FROM bronze.payments
    WHERE TRIM(ISNULL(CompanyId,''))     = ''
       OR TRIM(ISNULL(DocumentNumber,'')) = ''
	   OR TRIM(ISNULL(InvoiceNumber,'')) = ''
       OR TRY_CONVERT(DATE, PostingDate, 104) IS NULL
       OR TRY_CAST(Amount AS DECIMAL(18,8)) IS NULL
	;

    MERGE silver.payment AS t
    USING (
        SELECT
            CAST(TRIM(CompanyId) AS VARCHAR(10))                      AS CompanyId,
            CAST(TRIM(DocumentNumber) AS VARCHAR(50))                 AS PaymentNumber,
            CAST(COALESCE(TRIM(DocumentType), 'XNA') AS VARCHAR(20))  AS PaymentType,
            CAST(COALESCE(TRIM(CustomerId), 'XNA') AS VARCHAR(20))    AS CustomerId,
            CAST(COALESCE(UPPER(TRIM(CountryId)), 'XX') AS CHAR(2))   AS CountryId,
            TRY_CONVERT(DATE, PostingDate, 104)                       AS PostingDate,
            CAST(TRIM(Entry)  AS VARCHAR(20))                         AS Entry,
            CAST(NULLIF(TRIM(EntryType),'') AS VARCHAR(20))           AS EntryType,
            TRY_CAST(Amount AS DECIMAL(18,8))                         AS Amount,
            CAST(COALESCE(TRIM(InvoiceNumber), 'XNA') AS VARCHAR(50)) AS InvoiceNumber,
            CAST(COALESCE(TRIM(InvoiceEntry), 'XNA')  AS VARCHAR(20)) AS InvoiceEntry
        FROM bronze.payments
		WHERE PipelineRunId = @BronzePipelineRunId
		AND TRIM(ISNULL(CompanyId,'')) <> ''
        AND TRIM(ISNULL(DocumentNumber,'')) <> ''
		AND TRIM(ISNULL(InvoiceNumber,'')) <> ''
        AND TRY_CONVERT(DATE, PostingDate, 104) IS NOT NULL
        AND TRY_CAST(Amount AS DECIMAL(18,8)) IS NOT NULL
    ) AS s
    ON  t.CompanyId     = s.CompanyId
    AND t.PaymentNumber = s.PaymentNumber
	AND t.InvoiceNumber = s.InvoiceNumber
    WHEN MATCHED AND (
	    t.PaymentType   <> s.PaymentType OR
		t.CustomerId    <> s.CustomerId OR
        t.CountryId     <> s.CountryId OR
		t.PostingDate   <> s.PostingDate OR
        t.Entry         <> s.Entry OR
		t.EntryType     <> s.EntryType OR
        t.Amount        <> s.Amount OR
        t.InvoiceEntry  <> s.InvoiceEntry)
	THEN UPDATE SET
        t.PaymentType   = s.PaymentType,
		t.CustomerId    = s.CustomerId,
        t.CountryId     = s.CountryId, 
		t.PostingDate   = s.PostingDate,
        t.Entry         = s.Entry,       
		t.EntryType     = s.EntryType,
        t.Amount        = s.Amount,      
        t.InvoiceEntry  = s.InvoiceEntry,
	    t.DeletedFlag = 0,
        t.UpdatedTs  = GETUTCDATE(),
        t.UpdatedRunId = @PipelineRunId
    WHEN NOT MATCHED THEN INSERT (
        CompanyId, PaymentNumber, PaymentType, CustomerId, CountryId,
        PostingDate, Entry, EntryType, Amount, InvoiceNumber, InvoiceEntry,
        DeletedFlag, InsertedTs, UpdatedTs, InsertedRunId, UpdatedRunId
        ) VALUES (
		s.CompanyId, s.PaymentNumber, s.PaymentType, s.CustomerId, s.CountryId,
		s.PostingDate, s.Entry, s.EntryType, s.Amount, s.InvoiceNumber, s.InvoiceEntry, 
		0, GETUTCDATE(), GETUTCDATE(), @PipelineRunId, @PipelineRunId
		)
    WHEN NOT MATCHED BY SOURCE THEN UPDATE SET 
        t.DeletedFlag = 1,
        t.UpdatedRunId = @PipelineRunId
    ;
END