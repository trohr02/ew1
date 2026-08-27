CREATE TABLE [bronze].[pipeline_info] (

	[PipelineName] varchar(120) NULL, 
	[PipelineId] varchar(50) NULL, 
	[PipelineRunId] varchar(50) NULL, 
	[PipelineStartTs] datetime2(6) NULL, 
	[ActivityStartTs] datetime2(6) NULL
);