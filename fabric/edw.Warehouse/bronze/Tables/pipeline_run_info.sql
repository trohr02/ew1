CREATE TABLE [bronze].[pipeline_run_info] (

	[PipelineRunId] varchar(50) NULL, 
	[PipelineName] varchar(120) NULL, 
	[PipelineId] varchar(50) NULL, 
	[PipelineStartTs] datetime2(6) NULL, 
	[InsertedTs] datetime2(6) NULL
);