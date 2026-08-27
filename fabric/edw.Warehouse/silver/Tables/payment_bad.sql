CREATE TABLE [silver].[payment_bad] (

	[CompanyId] varchar(4000) NULL, 
	[PaymentNumber] varchar(4000) NULL, 
	[PostingDate] varchar(4000) NULL, 
	[Amount] varchar(4000) NULL, 
	[RejectReason] varchar(500) NULL, 
	[PipelineRunId] varchar(50) NULL, 
	[InsertedTs] datetime2(6) NULL
);