from datetime import datetime
import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

# Define paths for dbt project and profiles
DBT_PROJECT_DIR = '/home/airflow/airflow/sample-dbt-poc_new'  # Replace with actual dbt project path

# Define default arguments for DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': pendulum.datetime(2024, 3, 1, tz="UTC"),
    'retries': 1,
}

# Define the DAG
with DAG(
    dag_id="databricks_poc",
    default_args=default_args,
    description="DAG to run dbt transformations for Postgres and Databricks",
    schedule_interval=None,
    catchup=False,
    tags=["dbt", "databricks", "postgres"],
) as dag:
    
    # dbt Run Task for Silver Models (Postgres)
    dbt_run_postgres = BashOperator(
        task_id="dbt_run_postgres",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir . --profile postgres_transformation --target dev",
    )
    
    # dbt Run Task for Gold Models (Databricks)
    dbt_run_databrick = BashOperator(
        task_id="dbt_run_databrick",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir . --profile databricks_transformation --target dev",
    )
    
    # Define task dependencies
    dbt_run_postgres >> dbt_run_databrick