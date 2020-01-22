This directory contains the scripts used to create the `idc-dev-etl.idc.dicom_all` table (https://console.cloud.google.com/bigquery?project=idc-dev-etl&p=idc-dev-etl&d=idc&t=dicom_all&page=table) by merging the individual tcga tables in the chc-tcia project (console.cloud.google.com/bigquery?project=chc-tcia) .

 
Workflow

1. Visual inspection of the chc-tcia identified 21 tcga tables. Their names are recorded in a list in the tcga_collections.txt file. 

2. Using the tcga_collections.txt file data_columns_tcga.py created a matrix of all column names with column structure across all the 21 tcga tables. This matrix was saved in the collectionXdata_column sheet in the chc_tcia_bq_summary.xls file (https://docs.google.com/spreadsheets/d/1jznUNGJ9tAlDJ4ke7S2NjeoBcK2BgqrZ/edit#gid=125790953). The sheet is transposed from the output of the data_columns_tcga.py script.

3. From visual inspection I determined 14 columns with the same names but different structures across the tcga tables. These are recorded in the 'columns w different structures' sheet in the same spreadsheet file.

4. get_tcga_schema_json.x retrieved the 21 tcga table schemas in json format and placed them in the schema directory

5. mergeschemas.py then merges all these schemas into one schema that defines the dicom_all table. The 'skip_columns.txt' file is used to list certain columns that are not included in the merged schema. This includes the 14 columns that have different structures across the collections and the Rows column. At the time I thought Rows was a bigquery artifact and not a Dicom attribute but I may have been mistaken

6. The merged schema was used to create the `idc-dev-etl.idc.dicom_all` table (through the bigquery ui I beleive).

7. mergedata.py then copies the data from the chc-tcia tables to the dicom_all table   
