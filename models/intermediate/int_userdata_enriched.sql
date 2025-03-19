{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{source('s3_data', 'userdata')}}

),

cleaned as (
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
        --try_cast(birthdate as date) as birthdate,
       -- birthdate::date as birthdate,
        {{ cast_to_date('birthdate') }} AS birthdate,
        salary,
        title,
        comments
    from source
    where country is not null
)

select * from cleaned