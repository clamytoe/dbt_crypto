{{ config(materialized='table')}}

with coins as (
    select *
    from {{ ref('fact_coins') }}
)

select
    timestamp_trunc(timestamp, hour) as timestamp,
    avg(price_usd) as price_avg,
    avg(supply) as supply_avg,
    avg(volume_usd_24hr) as volume_avg,
    avg(change_percent_24hr) as change_percent_avg
from coins
where id = 'etherium'
group by `timestamp`
order by `timestamp` asc
