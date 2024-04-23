SELECT
            n_nationkey::string as nation_id,
            n_regionkey::string as region_id,
            n_name as nation,
            n_comment as nation_comment,
            r_name as region,
            r_comment as region_comment
        from
            {{ ref('stg_tpch__nations') }} nations
            left join {{ ref('stg_tpch__regions') }} regions on nations.n_regionkey = regions.r_regionkey