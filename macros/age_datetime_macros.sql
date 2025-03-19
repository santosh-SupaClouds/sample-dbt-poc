{% macro calculate_age(birthdate_column) %}
  {% if target.type in ['postgres', 'redshift', 'trino', 'starburst'] %}
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM {{ birthdate_column }})
  {% elif target.type == 'databricks' %}
    year(current_date()) - year({{ birthdate_column }})
  {% else %}
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM {{ birthdate_column }})
  {% endif %}
{% endmacro %}
