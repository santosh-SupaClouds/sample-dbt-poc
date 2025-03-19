{% macro current_timestamp() %}
  {% if target.type in ['postgres', 'redshift', 'trino', 'starburst'] %}
    CURRENT_TIMESTAMP
  {% elif target.type == 'databricks' %}
    current_timestamp()
  {% else %}
    CURRENT_TIMESTAMP
  {% endif %}
{% endmacro %}
