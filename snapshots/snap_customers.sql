{% snapshot snap_customers %}
    {{
        config(
            unique_key='customer_key',
            strategy='timestamp',
            updated_at='last_updated_at',
            target_schema=generate_schema_name('snaps')
        )
    }}

    select * from {{ ref('dim_customers') }}
 
 {% endsnapshot %}