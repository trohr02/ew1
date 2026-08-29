
DROP TABLE IF EXISTS gold.customer;
CREATE TABLE gold.customer
(
	CustomerId varchar(20) NOT NULL,
	CustomerName varchar(120) NOT NULL,
	CustomerCategory varchar(40) NOT NULL
);


DROP TABLE IF EXISTS gold.transaction_fact;
CREATE TABLE gold.transaction_fact
(
	CompanyId varchar(10) NOT NULL,
	InvoiceKey varchar(61) NOT NULL,
	DocumentKey varchar(61) NOT NULL,
	CustomerId varchar(20) NOT NULL,
	CountryId char(2) NOT NULL,
	PostingDate date NOT NULL,
	InvoiceDate date NULL,
	TransactionType varchar(20) NOT NULL,
	SignedAmount decimal(18,8) NULL,
	Amount decimal(18,8) NULL,
	SourceAmount decimal(18,8) NOT NULL
);


DROP TABLE IF EXISTS gold.invoice_balance_fact;
CREATE TABLE gold.invoice_balance_fact
(
	InvoiceKey varchar(61) NOT NULL,
	CustomerId varchar(20) NULL,
	CountryId char(2) NULL,
	InvoiceDate date NULL,
	InvoicedAmount decimal(38,8) NULL,
	PaymentAmount decimal(38,8) NULL,
	CreditNoteAmount decimal(38,8) NULL,
	RefundAmount decimal(38,8) NULL,
	FinanceChargeAmount decimal(38,8) NULL,
	RemainingAmount decimal(38,8) NULL
);




ALTER TABLE gold.customer
ADD CONSTRAINT PK_gold_customer
PRIMARY KEY NONCLUSTERED (CustomerId) NOT ENFORCED;


ALTER TABLE gold.transaction_fact
ADD CONSTRAINT FK_gold_transaction_fact_customer
FOREIGN KEY (CustomerId) REFERENCES gold.customer (CustomerId) NOT ENFORCED;


ALTER TABLE gold.invoice_balance_fact
ADD CONSTRAINT FK_gold_invoice_balance_fact_customer
FOREIGN KEY (CustomerId) REFERENCES gold.customer (CustomerId) NOT ENFORCED;
