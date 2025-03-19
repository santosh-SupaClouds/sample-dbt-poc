# import pendulum
# from airflow import DAG
# from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
# from airflow.operators.bash import BashOperator
# from airflow.operators.python import PythonOperator
# from airflow.providers.databricks.operators.databricks import DatabricksRunNowOperator

# # Define paths for dbt project and profiles
# DBT_PROJECT_DIR = '/home/airflow/airflow/qms_dev'  # Replace with actual dbt project path
# DBT_PROFILES_DIR = '/opt/airflow/.dbt'  # Replace with actual profiles directory
 
# # Define environment variables for Databricks connection
# ENV_VARS = {
#     'DATABRICKS_HOST': '{{ var.value.databricks_host }}',
#     'DATABRICKS_HTTP_PATH': '{{ var.value.databricks_http_path }}',
#     'DATABRICKS_TOKEN': '{{ var.value.databricks_token }}',
# }

# with DAG(
#     dag_id="databricks_iceberg_transformation",
#     start_date=pendulum.datetime(2024, 3, 1, tz="UTC"),
#     schedule_interval="@daily",
#     catchup=False,
# ) as dag:
 
#     # dbt Run Task for Postgres Models using BashOperator (if needed)
#     dbt_run_postgres = BashOperator(
#         task_id="dbt_run_postgres",
#         bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR} --profile postgres_transformation --target dev",
#         env=ENV_VARS,
#     )
 
#     # dbt Run Task for Databricks Models using BashOperator
#     dbt_run_databricks = BashOperator(
#         task_id="dbt_run_databricks",
#         bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR} --profile databricks_transformation --target dev",
#         env=ENV_VARS,
#     )
    
#     # Optional: Add a Databricks job to optimize Iceberg tables
#     optimize_iceberg_tables = DatabricksRunNowOperator(
#         task_id="optimize_iceberg_tables",
#         job_id="{{ var.value.optimize_iceberg_job_id }}",  # Set this in Airflow variables
#         notebook_params={
#             "table_names": "sample-poc.default.country_aggregation", 
#             "s3_location": "s3://test-kr9948/sample_dbt/iceberg-output/"
#         },
#     )
 
#     # Task Dependencies
#     dbt_run_postgres >> dbt_run_databricks >> optimize_iceberg_tables