{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('stg_userdata') }}
),

enriched as (
    select
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
        {{ calculate_age('birthdate') }} as age,
        title,
        comments,
        case 
            when salary < 50000 then 'Low'
            when salary between 50000 and 100000 then 'Medium'
            when salary > 100000 then 'High'
            else 'Unknown'
        end as salary_bracket
    from source
    where country is not null
)

select * from enriched