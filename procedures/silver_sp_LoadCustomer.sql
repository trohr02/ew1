/* 
============================================================================
Procedure : silver.sp_LoadCustomer
Target:     silver.customer
============================================================================   
Loads bronze.customer from bronze.customers
Method: Merg, soft delete 
============================================================================
*/
CREATE OR ALTER PROCEDURE silver.sp_LoadCustomer
    @PipelineRunId VARCHAR(50)
AS
BEGIN
    DECLARE @BronzePipelineRunId VARCHAR(50);

    SELECT TOP (1) @BronzePipelineRunId = PipelineRunId
    FROM bronze.pipeline_run_info
	WHERE PipelineName = 'Pipeline_Bronze'
    ORDER BY InsertedTs DESC
    ;
	
    MERGE silver.customer AS t
    USING (
        SELECT
            TRIM(CustomerId)  AS CustomerId,
            COALESCE(TRIM(CustomerName), 'N/A') AS CustomerName,
            COALESCE(TRIM(CustomerCategory), 'XNA') AS CustomerCategory
        FROM bronze.customers
		WHERE PipelineRunId = @BronzePipelineRunId
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
		t.UpdatedRunId     = @PipelineRunId
    WHEN NOT MATCHED THEN INSERT (
        CustomerId, CustomerName, CustomerCategory, DeletedFlag, 
		InsertedTs, UpdatedTs, InsertedRunId, UpdatedRunId
        ) VALUES (
		s.CustomerId, s.CustomerName, s.CustomerCategory, 0,
        GETUTCDATE(), GETUTCDATE(), @PipelineRunId, @PipelineRunId
		)
    WHEN NOT MATCHED BY SOURCE THEN UPDATE SET 
        t.DeletedFlag = 1,
        t.UpdatedRunId = @PipelineRunId
	;
END
GO
