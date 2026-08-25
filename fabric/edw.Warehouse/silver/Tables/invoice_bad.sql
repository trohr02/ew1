CREATE TABLE [silver].[invoice_bad] (

	[CompanyId] varchar(4000) NULL, 
	[InvoiceNumber] varchar(4000) NULL, 
	[PostingDate] varchar(4000) NULL, 
	[Amount] varchar(4000) NULL, 
	[reject_reason] varchar(500) NULL, 
	[_quarantine_ts] datetime2(6) NULL
);