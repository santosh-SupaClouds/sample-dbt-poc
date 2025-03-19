{% macro get_iceberg_config(model_name) %}
  {% set config_dict = {
    "file_format": "iceberg",
    "location": "s3://test-kr9948/sample_dbt/iceberg-output/" ~ model_name,
    "tblproperties": {
      "write.format.default": "parquet",
      "write.metadata.compression-codec": "gzip",
      "write.parquet.compression-codec": "snappy"
    }
  } %}
  {{ return(config_dict) }}
{% endmacro %}

{% macro create_external_table_as(table_name, schema_name, sql, location, file_format='iceberg') %}
  {% if file_format == 'iceberg' %}
    CREATE OR REPLACE TABLE {{ schema_name }}.{{ table_name }}
    USING ICEBERG
    LOCATION '{{ location }}'
    TBLPROPERTIES (
      'write.format.default' = 'parquet',
      'write.metadata.compression-codec' = 'gzip',
      'write.parquet.compression-codec' = 'snappy'
    )
    AS {{ sql }}
  {% else %}
    {{ exceptions.raise_compiler_error("Unsupported file format: " ~ file_format) }}
  {% endif %}
{% endmacro %}