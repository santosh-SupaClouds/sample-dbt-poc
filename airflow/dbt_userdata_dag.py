from airflow import DAG
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'dbt_userdata_transformation',
    default_args=default_args,
    description='A DAG to run DBT Cloud job for userdata transformation',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2025, 3, 1),
    catchup=False
)

dbt_run = DbtCloudRunJobOperator(
    task_id='dbt_cloud_run_job',
    job_id=12345,  # Replace with your actual job ID
    check_interval=10,
    timeout=300,
    dag=dag
)
