{% snapshot snap_customers %}
    {{
        config(
            unique_key='customer_key',
            strategy='timestamp',
            updated_at='__load_date'
        )
    }}

    select * from {{ ref('dim_customers') }}
 
 {% endsnapshot %}