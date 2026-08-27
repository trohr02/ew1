CREATE TABLE [bronze].[invoices] (

	[CompanyId] varchar(4000) NULL, 
	[CustomerId] varchar(4000) NULL, 
	[CountryId] varchar(4000) NULL, 
	[DocumentNumber] varchar(4000) NULL, 
	[DocumentType] varchar(4000) NULL, 
	[PostingDate] varchar(4000) NULL, 
	[Entry] varchar(4000) NULL, 
	[EntryType] varchar(4000) NULL, 
	[Amount] varchar(4000) NULL, 
	[PipelineRunId] varchar(50) NOT NULL, 
	[ActivityName] varchar(120) NOT NULL, 
	[IngestedTs] datetime2(6) NOT NULL, 
	[SourceFile] varchar(1000) NOT NULL
);