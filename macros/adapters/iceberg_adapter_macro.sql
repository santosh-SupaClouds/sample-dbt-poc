/*
* File: macros/adapters/iceberg_adapter_macro.sql
* 
* PURPOSE:
* This macro extends dbt's capabilities to properly handle Iceberg table formats in Databricks.
* By default, dbt's Databricks adapter is optimized for Delta Lake format, but this custom macro
* allows us to create Iceberg tables with specific configurations that ensure compatibility with S3
* storage and provide performance optimizations.
*
* WHY WE NEED THIS:
* 1. Standard dbt Databricks adapter doesn't natively support all Iceberg-specific configurations
* 2. We need to specify custom TBLPROPERTIES for Iceberg tables to optimize performance
* 3. This enables direct writing to S3 locations with proper Iceberg metadata
* 4. It allows us to configure compression codecs and storage formats specifically for Iceberg
* 
* USAGE IN PROJECT:
* When a model is configured with file_format='iceberg', this macro intercepts the CREATE TABLE AS
* statement and generates Iceberg-specific SQL instead of the default behavior. This is particularly
* important for our marts layer which needs to be persisted in S3 using Iceberg format.
*/

{% macro databricks__create_table_as(temporary, relation, sql) -%}
  {%- set file_format = config.get('file_format', default='delta') -%}
  
  {%- if file_format == 'iceberg' -%}
    {%- set location = config.get('location', default=none) -%}
    {%- set tblproperties = config.get('tblproperties', default={}) -%}
    
    CREATE OR REPLACE TABLE {{ relation }}
    USING ICEBERG
    {% if location is not none %}
    LOCATION '{{ location }}'
    {% endif %}
    {% if tblproperties %}
    TBLPROPERTIES (
      {% for key, value in tblproperties.items() %}
      '{{ key }}' = '{{ value }}'{% if not loop.last %},{% endif %}
      {% endfor %}
    )
    {% endif %}
    AS
    {{ sql }}
  
  {%- else -%}
    {# Use the default implementation for other file formats #}
    {{ create_table_as(temporary, relation, sql) }}
  {%- endif -%}
  
{%- endmacro %}