select *
from {{ ref('fct_tpch__parts') }}
where 
  1=1
  and supplier_id is not null
  and part_material ilike '%brass'
