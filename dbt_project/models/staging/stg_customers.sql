with source as (
    select * from {{ ref('raw_customers') }}
)

select
    customer_id,
    trim(customer_name) as customer_name,
    trim(region)        as region
from source
