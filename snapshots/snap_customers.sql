{% snapshot snap_customers %}
    {{
        config(
            unique_key='customer_key',
            strategy='timestamp',
            updated_at='last_updated_at'
        )
    }}

    select * from {{ ref('dim_customers') }}
 
 {% endsnapshot %}