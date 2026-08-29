CREATE TABLE [bronze].[customers] (

	[CustomerId] varchar(4000) NULL, 
	[CustomerName] varchar(4000) NULL, 
	[CustomerCategory] varchar(4000) NULL, 
	[PipelineRunId] varchar(50) NOT NULL, 
	[ActivityName] varchar(120) NOT NULL, 
	[IngestedTs] datetime2(6) NOT NULL, 
	[SourceFile] varchar(1000) NOT NULL
);