CREATE TABLE [bronze].[payment] (

	[CompanyId] varchar(4000) NULL, 
	[PaymentNumber] varchar(4000) NULL, 
	[PaymentType] varchar(4000) NULL, 
	[CustomerId] varchar(4000) NULL, 
	[CountryId] varchar(4000) NULL, 
	[PostingDate] varchar(4000) NULL, 
	[Entry] varchar(4000) NULL, 
	[EntryType] varchar(4000) NULL, 
	[Amount] varchar(4000) NULL, 
	[InvoiceNumber] varchar(4000) NULL, 
	[InvoiceEntry] varchar(4000) NULL, 
	[DeletedFlag] varchar(4000) NULL, 
	[IngestedTs] datetime2(6) NULL, 
	[SourceFile] varchar(1000) NULL
);