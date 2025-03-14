-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Create an external table in Unity Catalog
-- MAGIC
-- MAGIC This notebook shows how to create an external table in Unity Catalog from a Delta table in the `samples` catalog. The data for an external table is stored in a path in your cloud tenant's storage, outside the default storage location for a metastore. When you drop an external table, its underlying data is not deleted.
-- MAGIC
-- MAGIC Before you can create an external table, you must create a storage credential that allows Unity Catalog to read from and write to the path on your cloud tenant, and an external location that references it.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Requirements
-- MAGIC - In Azure, create a service principal and grant it the **Azure Blob Contributor** role on your storage container.
-- MAGIC - In Azure, create a client secret for your service principal. Make a note of the client secret, the directory ID, and the application ID for the client secret.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Create a storage credential
-- MAGIC
-- MAGIC You can create a storage credential using the Catalog Explorer or the Unity Catalog CLI. Follow these steps to create a storage credential using Catalog Explorer.
-- MAGIC
-- MAGIC 1. In a new browser tab, log in to Databricks.
-- MAGIC 3. Click **Catalog**.
-- MAGIC 4. Click **Storage Credentials**.
-- MAGIC 5. Click **Create Credential**.
-- MAGIC 6. Enter **example_credential** for he name of the storage credential.
-- MAGIC 7. Set **Client Secret**, **Directory ID**, and **Application ID** to the values for your service principal.
-- MAGIC 8. Optionally enter a comment for the storage credential.
-- MAGIC 9. Click **Save**.
-- MAGIC
-- MAGIC Leave this browser open for the next steps.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Create an external location
-- MAGIC An external location references a storage credential and also contains a storage path on your cloud tenant. The external location allows reading from and writing to only that path and its child directories. You can create an external location from Catalog Explorer, a SQL command, or the Unity Catalog CLI. Follow these steps to create an external location using Catalog Explorer.
-- MAGIC
-- MAGIC 1. Go to the browser tab where you just created a storage credential.
-- MAGIC 2. Click **Catalog**.
-- MAGIC 3. Click **External Locations**.
-- MAGIC 4. Click **Create location**.
-- MAGIC 5. Enter **example_location** for the name of the external location.
-- MAGIC 6. Enter the storage container path for the location allows reading from or writing to.
-- MAGIC 7. Set **Storage Credential** to **example_credential** to the storage credential you just created.
-- MAGIC 8. Optionally enter a comment for the external location.
-- MAGIC 9. Click **Save**.

-- COMMAND ----------

-- Grant access to create tables in the external location
GRANT USE CATALOG
ON example_catalog
TO `all users`;

GRANT USE SCHEMA
ON example_catalog.example_schema
TO `all users`;

GRANT CREATE EXTERNAL TABLE
ON LOCATION example_location
TO `all users`;

-- COMMAND ----------

-- Create an example catalog and schema to contain the new table
CREATE CATALOG IF NOT EXISTS example_catalog;
USE CATALOG example_catalog;
CREATE SCHEMA IF NOT EXISTS example_schema;
USE example_schema;

-- COMMAND ----------

-- Create a new external Unity Catalog table from an existing table
-- Replace <bucket_path> with the storage location where the table will be created
CREATE TABLE IF NOT EXISTS trips_external
LOCATION 'abfss://<bucket_path>'
AS SELECT * from samples.nyctaxi.trips;

-- To use a storage credential directly, add 'WITH (CREDENTIAL <credential_name>)' to the SQL statement.

-- COMMAND ----------

-- Describe the new table
DESCRIBE TABLE EXTENDED trips_external;

-- COMMAND ----------

-- Select from the new table
SELECT * FROM example_catalog.example_schema.trips_external;

-- COMMAND ----------

-- Drop the table. The underlying data files are not removed from cloud storage.
DROP TABLE IF EXISTS trips_external;
