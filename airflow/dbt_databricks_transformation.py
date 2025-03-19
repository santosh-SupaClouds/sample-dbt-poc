import pendulum
from airflow import DAG
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.operators.bash import BashOperator

 
# Define paths for dbt project and profiles
DBT_PROJECT_DIR = '/home/airflow/airflow/qms_dev'  # Replace with actual dbt project path
DBT_PROFILES_DIR = '/opt/airflow/.dbt'  # Replace with actual profiles directory
 
with DAG(
    dag_id="databricks_poc",
    start_date=pendulum.datetime(2024, 3, 1, tz="UTC"),
    schedule_interval=None,
    catchup=False,
) as dag:
 
 
    # dbt Run Task for Silver Models using BashOperator
    dbt_run_postgres = BashOperator(
        task_id="dbt_run_postgres",
        #bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR} --target silver --models sl_tkw",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR} --profile postgres_transformation --target dev" ,
    )
 
    # dbt Run Task for Gold Models using BashOperator
    dbt_run_databrick = BashOperator(
        task_id="dbt_run_databrick",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR} --profile databricks_transformation --target dev",
    )
 
    # Task Dependencies: Airbyte → dbt Silver → dbt Gold
    dbt_run_postgres >> dbt_run_databrick
#      sl_tkw_pr_addtl_data:

