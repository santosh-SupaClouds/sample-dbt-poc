# Databricks Transformation DBT Project

This DBT project reads user data from parquet files in S3 and performs country-wise aggregation, storing the results in the Databricks catalog.

## Project Structure

```
databricks_transformation/
├── models/
│   ├── staging/
│   │   └── stg_userdata.sql        # Staging model for raw user data
│   ├── intermediate/
│   │   └── int_userdata_enriched.sql   # Enriched user data with calculated fields
│   ├── marts/
│   │   └── country_aggregation.sql     # Final country-wise aggregation
│   ├── schema.yml                  # Model schema definitions and tests
│   └── sources.yml                 # Source data definitions
├── macros/                         # Custom macros (empty)
├── tests/                          # Custom tests (empty)
├── dbt_project.yml                 # Project configuration
├── profiles.yml                    # Connection profiles
├── packages.yml                    # Package dependencies
├── requirements.txt                # Python dependencies
├── .env.example                    # Environment variables template
├── .env                            # Environment variables (not versioned)
└── Makefile                        # Automation for setup and commands
```

## Quick Start with Makefile

The project includes a Makefile to automate common tasks. Here's how to get started:

```bash
# Complete setup (virtual env, dependencies, etc.)
make setup

# Update your .env file with your credentials
nano .env

# Debug your connection
make debug

# Run the transformation
make run

# Run tests
make test
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make setup` | Complete environment setup |
| `make env` | Create .env file from template |
| `make install` | Install Python dependencies |
| `make deps` | Install dbt packages |
| `make debug` | Debug dbt connection |
| `make compile` | Compile dbt models |
| `make run` | Run all dbt models |
| `make run-select MODELS=model_name` | Run specific models |
| `make test` | Run dbt tests |
| `make docs` | Generate and serve dbt docs |
| `make clean` | Clean dbt artifacts |
| `make clean-all` | Clean all artifacts including virtual environment |
| `make create-dirs` | Create project directories |
| `make setup-profiles` | Set up profiles.yml in ~/.dbt/ |
| `make help` | Show all available commands |

## Complete Setup Guide

### 1. Initial Setup with Makefile

```bash
# Clone the repository
git clone <repository-url>
cd databricks_transformation

# Setup the environment, virtual env, and dependencies
make setup

# Configure your credentials (edit the .env file)
nano .env

# Set up profiles.yml
make setup-profiles

# Debug to ensure connection works
make debug
```

### 2. Environment Configuration

The `.env` file contains environment variables needed for the project:

```
# Databricks credentials
DBT_DATABRICKS_TOKEN=your_databricks_token
DBT_DATABRICKS_HOST=dbc-839ef052-8f1c.cloud.databricks.com
DBT_DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/6c7973273ad09013

# AWS S3 credentials
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=us-east-1

# S3 bucket configuration
S3_BUCKET_NAME=your-bucket-name
S3_PATH_PREFIX=path/to/userdata/
```

### 3. Running the DBT Project

```bash
# Install dependencies (if not done with setup)
make deps

# Compile the models to validate
make compile

# Run all models
make run

# Run specific models
make run-select MODELS=stg_userdata
make run-select MODELS=country_aggregation
make run-select MODELS=staging+
```

### 4. Testing and Documentation

```bash
# Run tests
make test

# Generate and serve documentation
make docs
```

### 5. Manual Virtual Environment Usage

If you prefer to work directly with the virtual environment:

```bash
# Activate the virtual environment
source dbt-env/bin/activate  # On Linux/macOS
# dbt-env\Scripts\activate    # On Windows

# Deactivate when finished
deactivate
```

### 6. Deployment to Databricks

The country_aggregation model is configured to write to:
- Catalog: `main`
- Schema: `analytics`
- Table: `country_aggregation`

You can access this data in Databricks using SQL:

```sql
SELECT * FROM main.analytics.country_aggregation
```

### 7. Airflow Integration

To set up the Airflow integration:

1. Add the DAG file to your Airflow DAGs directory:
   ```bash
   cp airflow/dags/dbt_databricks_dag.py /path/to/airflow/dags/
   ```

2. Set the Airflow variable for Databricks token:
   ```bash
   airflow variables set dbt_databricks_token your_databricks_token
   ```

3. Update the path in the DAG file to point to your project directory:
   ```python
   # Edit line in dbt_databricks_dag.py
   bash_command='cd /path/to/dbt/project && dbt run --target prod',
   ```

### 8. Troubleshooting

- **Connection issues**: Ensure your token is correct and has the appropriate permissions
- **S3 access**: Verify IAM roles or credentials are correctly configured
- **Path issues**: Double check all path references in your models and configuration files
- **Virtual environment problems**: Try `make clean-all` and then `make setup` again

## Data Schema

The source data consists of parquet files with the following structure:
- Files: userdata[1-5].parquet
- Rows per file: ~1000
- Format: Parquet

### Column Definitions

| Column # | Column Name | Data Type |
|----------|-------------|-----------|
| 1 | registration_dttm | timestamp |
| 2 | id | int |
| 3 | first_name | string |
| 4 | last_name | string |
| 5 | email | string |
| 6 | gender | string |
| 7 | ip_address | string |
| 8 | cc | string |
| 9 | country | string |
| 10 | birthdate | string |
| 11 | salary | double |
| 12 | title | string |
| 13 | comments | string |

## Final Transformation

The final `country_aggregation` model provides the following metrics per country:
- Total users
- Average, minimum, maximum, and median salary
- Total salary sum
- Gender distribution
- Average age
- Salary bracket distribution