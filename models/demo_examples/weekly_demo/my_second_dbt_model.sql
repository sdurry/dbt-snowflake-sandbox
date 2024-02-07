with my_first_model as (

    select *
    from {{ ref('my_first_dbt_model') }}

), do_some_transformation as (

    select
        id + 1 as new_id,
        welcome_message
    from my_first_dbt_model

)

select *
from do_some_transformation
