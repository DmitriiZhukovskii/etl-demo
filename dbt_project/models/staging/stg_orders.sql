with source as (
    select * from {{ ref('raw_orders') }}
),

cleaned as (
    select
        order_id,
        customer_id,
        upper(trim(product_code))  as product_code,
        quantity,
        unit_price,
        cast(order_date as date)   as order_date,
        upper(trim(source_system)) as source_system,
        quantity * unit_price      as line_total
    from source
    where quantity > 0 and unit_price > 0
)

select * from cleaned
