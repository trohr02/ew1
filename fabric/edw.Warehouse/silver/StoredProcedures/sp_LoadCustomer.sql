CREATE   PROCEDURE silver.sp_LoadCustomer AS
BEGIN
    DECLARE @CurrentPipelineRunId VARCHAR(50);

    SELECT TOP (1) @CurrentPipelineRunId = PipelineRunId
    FROM bronze.pipeline_run_info
    ORDER BY InsertedTs DESC
    ;
	
    MERGE silver.customer AS t
    USING (
        SELECT
            TRIM(CustomerId)  AS CustomerId,
            COALESCE(TRIM(CustomerName), 'N/A') AS CustomerName,
            COALESCE(TRIM(CustomerCategory), 'XNA') AS CustomerCategory
        FROM bronze.customers
		WHERE PipelineRunId = @CurrentPipelineRunId
		  AND CustomerId is not null
    ) AS s
    ON t.CustomerId = s.CustomerId
    WHEN MATCHED AND (
        t.CustomerName     <> s.CustomerName OR
        t.CustomerCategory <> s.CustomerCategory)
    THEN UPDATE SET
        t.CustomerName     = s.CustomerName,
        t.CustomerCategory = s.CustomerCategory,
        t.DeletedFlag      = 1,
		t.UpdatedTs        = GETUTCDATE(),
		t.UpdatedRunId     = @CurrentPipelineRunId
    WHEN NOT MATCHED THEN INSERT (
        CustomerId, CustomerName, CustomerCategory, DeletedFlag, 
		InsertedTs, UpdatedTs, InsertedRunId, UpdatedRunId
        ) VALUES (
		s.CustomerId, s.CustomerName, s.CustomerCategory, 0,
        GETUTCDATE(), GETUTCDATE(), @CurrentPipelineRunId, @CurrentPipelineRunId
		)
    WHEN NOT MATCHED BY SOURCE THEN UPDATE SET 
        t.DeletedFlag = 1,
        t.UpdatedRunId = @CurrentPipelineRunId
	;
END