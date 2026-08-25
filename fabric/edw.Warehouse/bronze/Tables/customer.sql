CREATE TABLE [bronze].[customer] (

	[CustomerId] varchar(4000) NULL, 
	[CustomerName] varchar(4000) NULL, 
	[CustomerCategory] varchar(4000) NULL, 
	[DeletedFlag] varchar(4000) NULL, 
	[IngestedTs] datetime2(6) NULL, 
	[SourceFile] varchar(1000) NULL
);