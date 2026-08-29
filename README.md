# Architecture


**Data solution has 4 layers.**

- Lanfing - cloud storage where the source files and land.
- Bronze - snapshot of source data (possibly more snapshots)
- Silver - core data store with data transformed into designed and maintained data model
- Gold - layer for subject specific data transformed into report-ready shape

**Pipelines**

Pipelines move and transform data. `Landing -> Bronze -> Silver -> Gold` \  
Pipelines can be scheduled to periodically (or when triggered) update and refresh data
in our data solution,

- Pipeline_Bronze - read files from cloud storage and ingest into Bronze layer
- Pipeline_Silver - transform data from Bronze do Silver
- Pipeline_Gold  - refresh data in Gold layer

# Layers

## Bronze layer

 - One table per file ingested.
 - Capable of storing multiple snapshots of one file (multiple versions as they arrived)
 - Data from files loaded as "append" - one Pipeline run, one snapshot
 - Audit metadata for each snapshot.
 - TODO: Maintenance job which will delete old snapshot base on data governance rules
 - All data items as strings (varchar) without transformations
 
### Tables

| Table                    | Source                        |
| ------------------------ | ----------------------------- |
| bronze.customers         | customers.txt                 |
| bronze.invoices          | invoces.xlsx                  |
| bronze.payments          | payments.csv                  |
| bronze.pipeline_run_info | Metadata inserted by pipeline |

## Technical metadata and attributes

Each table has the following technical metadata attributes.\ 
Columns `PipelineRunId` identified one snapshot (batch).

| Column        | Note                                   |
| ------------- | -------------------------------------- |
| PipelineRunId | Run Id of pipeline which inserted data |
| ActivityName  | Pipeline Activity which inserted data  |
| IngestedTs    | Timestamp when row was inserted        |
| SourceFile    | Name of loaded source file             |

### Table pipeline_run_info

Audit metadata about run of Pipeline_Bronze. Can be joined to bronze tables using `PipelineRunInfo`

| Column          | Note                     |
| --------------- | ------------------------ |
| PipelineRunId   | Id of one pipeline run   |
| PipelineName    | Pipeline name            |
| PipelineId      | Pipeline Id              |
| PipelineStartTs | Pipeline start timestamp |
| InsertedTs      | Insertion timestamp      |

## Silver layer

![Silver ERD](img\silver_layer_erd.png)

- Designed data model
- Correct data types: decimal for monetary data, datetime for dates
- Basic data quality checks
  - Rows with data quality issues quarantined (invoice_bad, payment_bad)
  - Checks: PK null, wrong date string, wrong number string
- Idempotent load using MERGE statement
  - Soft-delete using column DeletedFlag (0 - active, 1 - deleted)
- Audit technical columns (see below)

| Table              | PK                         | Notes                                                     |
| ------------------ | -------------------------- | --------------------------------------------------------- |
| silver.customer    | CustomerId                 |                                                           |
| silver.invoice     | CompanyId<br>InvoiceNumber |                                                           |
| silver.payment     | CompanyId<br>PaymentNumber | There are other types of transactions, not just payments. |
| silver.invoice_bad |                            | Rows from bronze.invoices wi dat quality issues           |
| silver.payment_bad |                            | Rows from bronze.payments wi dat quality issues           |

### Metadata audit attributes

| Column         | Note                                      |
|----------------|-------------------------------------------|
| DeletedFlag    | 0 - active, 1 - deleted                   |
| InsertedTs     | Timestamp when row was inserted           |
| UpdatedTs      | Timestamp when row was updated            |
| InsertedRunId  | Rum Id of pipeline which inserted the row |
| UpdatedRunId   | Run Id of pipeline which updated the row  |


# Infrastructure

I used Microsoft Fabric Free Tier so maybe not all features were available to me. 
It comes with is own ADLS storage, so I used that instead of separate Storage Account.


