CREATE TABLE [silver].[customer] (

	[CustomerId] varchar(20) NOT NULL, 
	[CustomerName] varchar(120) NOT NULL, 
	[CustomerCategory] varchar(40) NOT NULL, 
	[DeletedFlag] char(1) NOT NULL, 
	[InsertedTs] datetime2(6) NULL
);


GO
ALTER TABLE [silver].[customer] ADD CONSTRAINT PK_silver_customer primary key NONCLUSTERED ([CustomerId]);