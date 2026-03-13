with stg_total as (
    select sum(line_total) as revenue from {{ ref('stg_orders') }}
),
mart_total as (
    select sum(total_revenue) as revenue from {{ ref('mart_customer_orders') }}
)

select
    s.revenue as staging_revenue,
    m.revenue as mart_revenue
from stg_total s
cross join mart_total m
where abs(s.revenue - m.revenue) > 0.01
