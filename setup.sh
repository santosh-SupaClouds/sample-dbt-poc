#!/bin/bash

# Set up colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up DBT project for Databricks transformation...${NC}"

# Create project directory
PROJECT_DIR="userdata_transformation"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Create directory structure
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p models/staging
mkdir -p models/intermediate
mkdir -p models/marts
mkdir -p macros
mkdir -p tests
mkdir -p seeds
mkdir -p snapshots
mkdir -p analyses

# Create dbt_project.yml
echo -e "${GREEN}Creating dbt_project.yml...${NC}"
cat > dbt_project.yml << 'EOF'
name: 'userdata_transformation'
version: '1.0.0'
config-version: 2

profile: 'userdata_transformation'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  userdata_transformation:
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
EOF

# Create profiles.yml in the project directory
echo -e "${GREEN}Creating profiles.yml in the project directory...${NC}"
cat > profiles.yml << 'EOF'
userdata_transformation:
  target: dev
  outputs:
    dev:
      type: databricks
      schema: default
      host: dbc-839ef052-8f1c.cloud.databricks.com
      http_path: /sql/1.0/warehouses/6c7973273ad09013
      token: <access-token>
      threads: 4
    prod:
      type: databricks
      schema: prod
      host: dbc-839ef052-8f1c.cloud.databricks.com
      http_path: /sql/1.0/warehouses/6c7973273ad09013
      token: <access-token>
      threads: 8
    test:
      type: databricks
      schema: test
      host: dbc-839ef052-8f1c.cloud.databricks.com
      http_path: /sql/1.0/warehouses/6c7973273ad09013
      token: <access-token>
      threads: 2
EOF

# Also create profiles.yml in the ~/.dbt directory for global access
echo -e "${GREEN}Creating profiles.yml in ~/.dbt directory...${NC}"
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
userdata_transformation:
  target: dev
  outputs:
    dev:
      type: databricks
      schema: default
      host: dbc-839ef052-8f1c.cloud.databricks.com
      http_path: /sql/1.0/warehouses/6c7973273ad09013
      token: <access-token>
      threads: 4
    prod:
      type: databricks
      schema: prod
      host: dbc-839ef052-8f1c.cloud.databricks.com
      http_path: /sql/1.0/warehouses/6c7973273ad09013
      token: <access-token>
      threads: 8
    test:
      type: databricks
      schema: test
      host: dbc-839ef052-8f1c.cloud.databricks.com
      http_path: /sql/1.0/warehouses/6c7973273ad09013
      token: <access-token>
      threads: 2
EOF

# Create staging model
echo -e "${GREEN}Creating staging model...${NC}"
cat > models/staging/stg_userdata.sql << 'EOF'
{{ config(
    materialized = 'view'
) }}

SELECT
    registration_dttm,
    id,
    first_name,
    last_name,
    email,
    gender,
    ip_address,
    cc,
    country,
    birthdate,
    salary,
    title,
    comments
FROM 
    parquet.`s3://your-bucket-path/userdata*.parquet`
EOF

# Create intermediate model
echo -e "${GREEN}Creating intermediate model...${NC}"
cat > models/intermediate/int_userdata_cleaned.sql << 'EOF'
{{ config(
    materialized = 'view'
) }}

SELECT
    registration_dttm,
    id,
    first_name,
    last_name,
    email,
    UPPER(gender) AS gender,
    ip_address,
    cc,
    COALESCE(country, 'Unknown') AS country,
    CAST(birthdate AS DATE) AS birthdate,
    COALESCE(salary, 0) AS salary,
    title,
    comments
FROM 
    {{ ref('stg_userdata') }}
WHERE 
    id IS NOT NULL
EOF

# Create country aggregation model
echo -e "${GREEN}Creating country aggregation model...${NC}"
cat > models/marts/country_aggregation.sql << 'EOF'
{{ config(
    materialized = 'table',
    catalog = 'main',
    schema = 'analytics'
) }}

SELECT
    country,
    COUNT(*) AS total_users,
    COUNT(DISTINCT id) AS unique_users,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_salary,
    COUNT(CASE WHEN LOWER(gender) = 'male' THEN 1 END) AS male_count,
    COUNT(CASE WHEN LOWER(gender) = 'female' THEN 1 END) AS female_count,
    MIN(birthdate) AS oldest_user_birthdate,
    MAX(birthdate) AS youngest_user_birthdate
FROM 
    {{ ref('int_userdata_cleaned') }}
GROUP BY 
    country
ORDER BY 
    total_users DESC
EOF

# Create schema.yml for documentation
echo -e "${GREEN}Creating schema.yml for documentation...${NC}"
cat > models/marts/schema.yml << 'EOF'
version: 2

models:
  - name: country_aggregation
    description: "Country-wise aggregation of user data"
    columns:
      - name: country
        description: "Country name"
      - name: total_users
        description: "Total number of users in the country"
      - name: unique_users
        description: "Number of unique users in the country"
      - name: avg_salary
        description: "Average salary of users in the country"
      - name: max_salary
        description: "Maximum salary of users in the country"
      - name: min_salary
        description: "Minimum salary of users in the country"
      - name: total_salary
        description: "Sum of all salaries in the country"
      - name: male_count
        description: "Number of male users in the country"
      - name: female_count
        description: "Number of female users in the country"
      - name: oldest_user_birthdate
        description: "Birthdate of the oldest user in the country"
      - name: youngest_user_birthdate
        description: "Birthdate of the youngest user in the country"
EOF

# Create Airflow DAG file
echo -e "${GREEN}Creating Airflow DAG file...${NC}"
mkdir -p airflow
cat > airflow/dbt_userdata_dag.py << 'EOF'
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
EOF
