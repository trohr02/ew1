CREATE TABLE [gold].[customer] (

	[CustomerId] varchar(20) NOT NULL, 
	[CustomerName] varchar(120) NOT NULL, 
	[CustomerCategory] varchar(40) NOT NULL
);


GO
ALTER TABLE [gold].[customer] ADD CONSTRAINT PK_gold_customer primary key NONCLUSTERED ([CustomerId]);