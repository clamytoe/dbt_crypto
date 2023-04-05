{{ config(materialized='view') }}

select

    -- identifiers
    cast(id as string) as id,

    -- timestamps
    cast(timestamp as timestamp) as timestamp,

    -- coin info
    cast(rank as integer) as rank,
    cast(symbol as string) as symbol,
    cast(name as string) as name,
    cast(supply as numeric) as supply,
    cast(market_cap_usd as numeric) as market_cap_usd,
    cast(volume_usd_24hr as numeric) as volume_usd_24hr,
    cast(price_usd as numeric) as price_usd,
    cast(change_percent_24hr as numeric) as change_percent_24hr,
    cast(url as string) as url

from {{ source('staging', 'coins') }}
