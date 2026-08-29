CREATE TABLE [gold].[invoice_balance_fact] (

	[InvoiceKey] varchar(61) NOT NULL, 
	[CustomerId] varchar(20) NULL, 
	[CountryId] char(2) NULL, 
	[InvoiceDate] date NULL, 
	[InvoicedAmount] decimal(38,8) NULL, 
	[PaymentAmount] decimal(38,8) NULL, 
	[CreditNoteAmount] decimal(38,8) NULL, 
	[RefundAmount] decimal(38,8) NULL, 
	[FinanceChargeAmount] decimal(38,8) NULL, 
	[RemainingAmount] decimal(38,8) NULL
);