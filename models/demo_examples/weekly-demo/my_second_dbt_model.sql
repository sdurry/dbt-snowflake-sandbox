with load_my_source_data as (

    select *
    from {{ ref('my_first_dbt_model') }}

), my_modular_transformation as (

    select 
        *
        ,'Great to have you all' as some_text
    from load_my_source_data

)

select 
    *
from my_modular_transformation
