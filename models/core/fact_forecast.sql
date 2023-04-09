{{ config(materialized='table')}}

WITH 
  intervals AS (
    SELECT
      symbol,
      DATE_TRUNC(MIN(timestamp), HOUR) AS start_time,
      DATE_TRUNC(MAX(timestamp), HOUR) AS end_time
    FROM
      {{ ref('stg_coins') }}
    GROUP BY
      symbol
  ),
  
  hour_seq AS (
    SELECT
      symbol,
      GENERATE_TIMESTAMP_ARRAY(start_time, end_time, INTERVAL 1 HOUR) AS hours
    FROM
      intervals
  ),
  
  filled AS (
    SELECT
      hour_seq.symbol,
      hour,
      IFNULL(sc.price_usd, LAG(sc.price_usd) OVER (PARTITION BY sc.symbol, hour ORDER BY sc.timestamp)) AS price_usd
    FROM
      hour_seq
      CROSS JOIN UNNEST(hour_seq.hours) AS hour
      LEFT JOIN
        {{ ref('stg_coins') }} sc
        ON sc.symbol = hour_seq.symbol
        AND TIMESTAMP_TRUNC(sc.`timestamp`, HOUR) = hour
    WHERE
      hour_seq.symbol = sc.symbol
  )

SELECT
  filled.symbol,
  filled.hour,
  AVG(filled.price_usd) AS avg_price_usd
FROM
  filled
GROUP BY
  filled.symbol,
  filled.hour
ORDER BY
  symbol,
  hour
