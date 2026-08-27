CREATE TABLE [silver].[payment] (

	[CompanyId] varchar(10) NOT NULL, 
	[PaymentNumber] varchar(50) NOT NULL, 
	[PaymentType] varchar(20) NOT NULL, 
	[CustomerId] varchar(20) NOT NULL, 
	[CountryId] char(2) NOT NULL, 
	[PostingDate] date NOT NULL, 
	[Entry] varchar(20) NULL, 
	[EntryType] varchar(20) NULL, 
	[Amount] decimal(18,8) NULL, 
	[InvoiceNumber] varchar(50) NOT NULL, 
	[InvoiceEntry] varchar(20) NOT NULL, 
	[DeletedFlag] int NOT NULL, 
	[InsertedTs] datetime2(6) NOT NULL, 
	[UpdatedTs] datetime2(6) NULL, 
	[InsertedRunId] varchar(50) NOT NULL, 
	[UpdatedRunId] varchar(50) NULL
);


GO
ALTER TABLE [silver].[payment] ADD CONSTRAINT PK_silver_payment primary key NONCLUSTERED ([CompanyId], [PaymentNumber], [InvoiceNumber]);