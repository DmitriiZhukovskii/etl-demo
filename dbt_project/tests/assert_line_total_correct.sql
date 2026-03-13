select
    order_id,
    quantity,
    unit_price,
    line_total,
    quantity * unit_price as expected_total
from {{ ref('stg_orders') }}
where abs(line_total - quantity * unit_price) > 0.01
