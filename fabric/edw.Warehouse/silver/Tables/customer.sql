CREATE TABLE [silver].[customer] (

	[CustomerId] varchar(20) NOT NULL, 
	[CustomerName] varchar(120) NOT NULL, 
	[CustomerCategory] varchar(40) NOT NULL, 
	[DeletedFlag] char(1) NOT NULL, 
	[InsertedTs] datetime2(6) NOT NULL, 
	[UpdatedTs] datetime2(6) NULL, 
	[InsertedRunId] varchar(50) NOT NULL, 
	[UpdatedRunId] varchar(50) NULL
);