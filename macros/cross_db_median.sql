{% macro median_salary(column_name) %}

  {% if target.type in ("postgres", "redshift") %}
    percentile_cont(0.5) WITHIN GROUP (ORDER BY {{ column_name }})
  
  {% elif target.type == "databricks" %}
    percentile_approx({{ column_name }}, 0.5)

  {% elif target.type == "starburst" %}
    approx_percentile({{ column_name }}, 0.5)

  {% else %}
    {{ exceptions.raise_compiler_error("Unsupported database: " ~ target.type) }}

  {% endif %}

{% endmacro %}
