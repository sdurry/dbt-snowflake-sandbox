select
    suppliers.s_suppkey as supplier_id,
    suppliers.s_nationkey as nation_id,
    parts.p_partkey as part_id,
    concat(s_suppkey, parts.p_partkey) as part_supplier_sk,
    suppliers.s_nationkey as supplier_nation,
    part_suppliers.ps_availqty as part_supplier_available_qty,
    part_suppliers.ps_supplycost as part_supplier_cost,
    part_suppliers.ps_comment as part_supplier_comment,
    suppliers.s_name as supplier_name,
    suppliers.s_address as supplier_address,
    suppliers.s_phone as supplier_phone_number,
    suppliers.s_acctbal as supplier_account_balance,
    suppliers.s_comment as supplier_comment,
    parts.p_name as part_name,
    parts.p_mfgr as part_manufacturer,
    parts.p_brand as part_brand,
    parts.p_type as part_type,
    parts.p_container as part_container,
    parts.p_retailprice as part_retail_price,
    case
        when parts.p_type like '%BRASS' then 'brass'
        else p_type
    end as part_material,
    parts.p_comment as part_comment
from
    SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER suppliers
    left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP part_suppliers on suppliers.s_suppkey = part_suppliers.ps_suppkey
    left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART parts on parts.p_partkey = part_suppliers.ps_partkey