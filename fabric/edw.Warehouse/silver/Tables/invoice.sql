CREATE TABLE [silver].[invoice] (

	[CompanyId] varchar(10) NOT NULL, 
	[InvoiceNumber] varchar(50) NOT NULL, 
	[InvoiceType] varchar(20) NOT NULL, 
	[PostingDate] date NOT NULL, 
	[CustomerId] varchar(20) NOT NULL, 
	[CountryId] char(2) NOT NULL, 
	[Entry] varchar(20) NULL, 
	[EntryType] varchar(20) NULL, 
	[Amount] decimal(18,8) NULL, 
	[DeletedFlag] int NOT NULL, 
	[InsertedTs] datetime2(6) NOT NULL, 
	[UpdatedTs] datetime2(6) NULL, 
	[InsertedRunId] varchar(50) NOT NULL, 
	[UpdatedRunId] varchar(50) NULL
);