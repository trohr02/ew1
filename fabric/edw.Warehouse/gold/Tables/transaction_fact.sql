CREATE TABLE [gold].[transaction_fact] (

	[CompanyId] varchar(10) NOT NULL, 
	[InvoiceKey] varchar(61) NOT NULL, 
	[DocumentKey] varchar(61) NOT NULL, 
	[CustomerId] varchar(20) NOT NULL, 
	[CountryId] char(2) NOT NULL, 
	[PostingDate] date NOT NULL, 
	[InvoiceDate] date NULL, 
	[TransactionType] varchar(20) NOT NULL, 
	[SignedAmount] decimal(18,8) NULL, 
	[Amount] decimal(18,8) NULL, 
	[SourceAmount] decimal(18,8) NOT NULL
);