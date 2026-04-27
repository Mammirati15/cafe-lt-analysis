/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Silver
 * Input: events table (Bronze)
 * Output: silver_events view
 * Purpose: Clean and standardize events table for analysis.
 *          Deduplicates offer completed events, parses JSON-like
 *          value field into clean columns, and excludes events
 *          belonging to invalid customer records.
 * Known Issues:
 *  396 duplicate rows in offer completed events — deduplicated here.
 *  value field uses single quotes and 'offer id' (with space) not
 *  standard JSON. Cleaned by replacing single quotes with double
 *  quotes and 'offer id' with 'offer_id' before JSON extraction.
 *  Events from 2,175 invalid customers excluded via join to silver_customers.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW silver_events AS

-- Deduplicate by assigning row numbers within duplicate groups.
-- We partition by all four columns so true duplicates get row numbers 2, 3 etc.
-- DuckDB: ROW_NUMBER() OVER (PARTITION BY ...)
-- Snowflake: same
WITH deduplicated AS (
    SELECT
        customer_id,
        event,
        value,
        time,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, event, value, time
            ORDER BY time
        ) AS row_num
    FROM events
),

-- Keep only the first occurrence of each row (row_num = 1)
-- This removes the 396 duplicate offer completed events
deduped_events AS (
    SELECT
        customer_id,
        event,
        value,
        time
    FROM deduplicated
    WHERE row_num = 1
)

-- Parse value field and filter invalid customers
SELECT
    e.customer_id,
    e.event,
    e.time,

    -- Parse offer_id from value field for offer events.
    -- Raw format uses single quotes and 'offer id' with a space
    -- (not regular for JSON). We normalize it before extracting.
    -- First, replace single quotes with double quotes
    -- Next,replace 'offer id' with 'offer_id' to fix the key name
    -- Then extract using JSON path syntax
    -- DuckDB: json_extract_string(replace(replace(...)))
    -- Snowflake equivalent: PARSE_JSON(value):offer_id::STRING
    --   I see that Snowflake handles single quotes natively with PARSE_JSON)
    CASE
        WHEN e.event != 'transaction'
        THEN json_extract_string(
            replace(replace(e.value, '''', '"'), 'offer id', 'offer_id'),
            '$.offer_id'
        )
        ELSE NULL
    END AS offer_id,

    -- Parse amount from value field for transaction events.
    -- Raw format: {'amount': 3.75}
    -- DuckDB: json_extract_string then cast to float
    -- Snowflake equivalent: PARSE_JSON(value):amount::FLOAT
    CASE
        WHEN e.event = 'transaction'
        THEN CAST(
            json_extract_string(
                replace(e.value, '''', '"'),
                '$.amount'
            ) AS FLOAT
        )
        ELSE NULL
    END AS amount

FROM deduped_events e

-- Exclude events belonging to invalid customer records.
-- Inner join to silver_customers ensures only valid customers
-- are included, the 2,175 invalid records are already excluded
-- from silver_customers so they will not match here.
INNER JOIN silver_customers sc
    ON e.customer_id = sc.customer_id;