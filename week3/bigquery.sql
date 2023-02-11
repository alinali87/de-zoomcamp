-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `<project>.<dataset>.external_fhv`
OPTIONS (
  format = 'CSV',
  uris = ['gs://<bucket>/fhv/fhv_tripdata_2019-*.csv.gz']
);

-- Create a table in BQ using the fhv 2019 data (do not partition or cluster this table)
CREATE OR REPLACE TABLE `<project>.<dataset>.fhv_non_partitioned` AS
SELECT * FROM `<project>.<dataset>.external_fhv`;

-- What is the count for fhv vehicle records for year 2019?
SELECT COUNT(*) FROM `<project>.<dataset>.external_fhv`

-- Count the distinct number of affiliated_base_number for the entire dataset on both the tables
SELECT COUNT(DISTINCT affiliated_base_number) FROM `<project>.<dataset>.external_fhv`
SELECT COUNT(DISTINCT affiliated_base_number) FROM `<project>.<dataset>.fhv_non_partitioned`

-- How many records have both a blank (null) PUlocationID and DOlocationID in the entire dataset?
SELECT COUNT(*)
FROM `<project>.<dataset>.fhv_non_partitioned`
WHERE PUlocationID IS NULL ANS DOlocationID IS NULL;

-- Create table optimized for filtering by pickup_datetime and ordering by affiliated_base_number
CREATE OR REPLACE TABLE `<project>.<dataset>.fhv_partitioned_clustered`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY Affiliated_base_number AS
SELECT * FROM `<project>.<dataset>.external_fhv`;

-- Retrieve the distinct affiliated_base_number between pickup_datetime 2019/03/01 and 2019/03/31 (inclusive)
SELECT DISTINCT affiliated_base_number
FROM `<project>.<dataset>.fhv_non_partitioned`
WHERE pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31'

SELECT DISTINCT affiliated_base_number
FROM `<project>.<dataset>.fhv_partitioned_clustered`
WHERE pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31'
