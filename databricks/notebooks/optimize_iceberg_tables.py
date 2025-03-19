# # File: databricks/notebooks/optimize_iceberg_tables.py
# #
# # PURPOSE:
# # This Databricks notebook is designed to perform maintenance operations on Iceberg tables
# # stored in S3. Iceberg tables require periodic optimization to maintain performance and
# # reduce storage costs, especially when dealing with frequently updated data or when
# # many small files accumulate over time.
# #
# # WHY WE NEED THIS:
# # 1. SMALL FILE PROBLEM:
# #    When many small operations write to Iceberg tables, they create numerous small files.
# #    This degrades query performance as Spark needs to open too many files during reads.
# #
# # 2. METADATA CLEANUP:
# #    Iceberg tracks historical versions of the data (snapshots), which consume storage space.
# #    Old snapshots need to be expired to keep metadata size manageable.
# #
# # 3. STORAGE COSTS:
# #    S3 charges per request, so having too many small files increases operational costs.
# #
# # 4. QUERY PERFORMANCE:
# #    Compacted tables with fewer, larger files perform significantly better for analytical queries.
# #
# # The notebook performs three key maintenance operations:
# # - VACUUM: Removes orphaned data files not referenced by the table metadata
# # - OPTIMIZE: Compacts small files into larger ones for better read performance
# # - EXPIRE_SNAPSHOTS: Removes old versions of the data to reduce metadata size
# #
# # This notebook is designed to be called from the Airflow DAG after dbt transformations are complete.

# # Databricks notebook source
# # COMMAND ----------

# # Get parameters
# dbutils.widgets.text("table_names", "", "Table Names (comma-separated)")
# dbutils.widgets.text("s3_location", "", "S3 Location")

# table_names = dbutils.widgets.get("table_names").split(",")
# s3_location = dbutils.widgets.get("s3_location")

# # COMMAND ----------

# # Optimize Iceberg tables
# for table_name in table_names:
#     if table_name.strip():
#         print(f"Optimizing table: {table_name}")
        
#         # Run vacuum to remove old snapshots and data files
#         spark.sql(f"VACUUM TABLE {table_name}")
        
#         # Run optimize to compact small files
#         spark.sql(f"OPTIMIZE {table_name}")
        
#         # Expire old snapshots to clean up metadata
#         spark.sql(f"ALTER TABLE {table_name} EXECUTE EXPIRE_SNAPSHOTS RETAIN 5 DAYS")
        
#         print(f"Optimization complete for: {table_name}")

# # COMMAND ----------

# # Verify table statistics
# for table_name in table_names:
#     if table_name.strip():
#         print(f"Statistics for table: {table_name}")
        
#         # Show table statistics
#         df = spark.sql(f"DESCRIBE DETAIL {table_name}")
#         display(df)
        
#         # Show file count and size
#         df = spark.sql(f"SELECT count(*) as file_count FROM {table_name}")
#         display(df)

# # COMMAND ----------