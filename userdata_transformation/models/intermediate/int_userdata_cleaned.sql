{{
    config(
        materialized='view'
    )
}}

with userdata as (
    select * from {{ ref('stg_userdata') }}
),

enriched as (
    select
        *,
        extract(year from current_date()) - extract(year from birthdate) as age,
        case
            when salary < 50000 then 'Low'
            when salary between 50000 and 100000 then 'Medium'
            when salary > 100000 then 'High'
            else 'Unknown'
        end as salary_bracket
    from userdata
)

select * from enriched