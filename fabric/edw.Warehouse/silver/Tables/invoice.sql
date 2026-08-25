CREATE TABLE [silver].[invoice] (

	[CompanyId] varchar(10) NOT NULL, 
	[InvoiceNumber] varchar(50) NOT NULL, 
	[InvoiceType] varchar(20) NOT NULL, 
	[PostingDate] date NOT NULL, 
	[CustomerId] varchar(20) NOT NULL, 
	[CountryId] char(2) NOT NULL, 
	[Entry] varchar(20) NOT NULL, 
	[EntryType] varchar(20) NOT NULL, 
	[Amount] decimal(18,8) NULL, 
	[InsertedTs] datetime2(6) NULL
);


GO
ALTER TABLE [silver].[invoice] ADD CONSTRAINT PK_silver_invoice primary key NONCLUSTERED ([CompanyId], [InvoiceNumber]);
GO
ALTER TABLE [silver].[invoice] ADD CONSTRAINT FK_silver_invoice_customer FOREIGN KEY ([CustomerId]) REFERENCES [silver].[customer]([CustomerId]);