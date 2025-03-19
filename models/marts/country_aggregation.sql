{{
    config(
        materialized='table',
        file_format='iceberg',
        location="s3://test-kr9948/sample_dbt/iceberg-output/country_aggregation",
        tblproperties={
            "write.format.default": "parquet",
            "write.metadata.compression-codec": "gzip",
            "write.parquet.compression-codec": "snappy"
        }
    )
}}

with user_data as (
    select * from {{ ref('int_userdata_enriched') }}
),

country_agg as (
    select
        country,
        count(*) as total_users,
        avg(salary) as avg_salary,
        min(salary) as min_salary,
        max(salary) as max_salary,
        {{ median_salary('salary') }} AS median_salary,
        sum(salary) as total_salary,
        count(case when gender = 'Male' then 1 end) as male_count,
        count(case when gender = 'Female' then 1 end) as female_count,
        avg({{ calculate_age('birthdate') }}) as avg_age,
        count(case when salary_bracket = 'Low' then 1 end) as low_salary_count,
        count(case when salary_bracket = 'Medium' then 1 end) as medium_salary_count,
        count(case when salary_bracket = 'High' then 1 end) as high_salary_count
    from user_data
    group by country
)

select 
    country,
    total_users,
    avg_salary,
    min_salary,
    max_salary,
    median_salary,
    total_salary,
    male_count,
    female_count,
    avg_age,
    low_salary_count,
    medium_salary_count,
    high_salary_count,
    {{ current_timestamp() }} AS processed_at
from country_agg
order by total_users desc