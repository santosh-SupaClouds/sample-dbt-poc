{% macro cast_to_date(column_name) %}
  {% if target.type in ['postgres', 'redshift', 'trino', 'starburst'] %}
    {{ column_name }}::DATE
  {% elif target.type == 'databricks' %}
    TRY_CAST({{ column_name }} AS DATE)
  {% else %}
    CAST({{ column_name }} AS DATE)
  {% endif %}
{% endmacro %}

