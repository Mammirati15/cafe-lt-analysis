/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Silver
 * Input: customers table (Bronze)
 * Output: silver_customers view
 * Purpose: Clean and standardize customers table for analysis.
 *          Excludes invalid records, casts date field, adds
 *          membership tenure in days.
 * Known Issues:
 *  2,175 records excluded (age=118, null income, null gender).
 *  became_member_on cast from integer (yyyymmdd) to proper date.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW silver_customers AS
SELECT
    customer_id,
    gender,
    age,
    income,

    -- Cast integer date to proper date format
    -- DuckDB: STRPTIME(CAST(became_member_on AS VARCHAR), '%Y%m%d')::DATE
    -- Snowflake equivalent: TO_DATE(CAST(became_member_on AS VARCHAR), 'YYYYMMDD')
    STRPTIME(CAST(became_member_on AS VARCHAR), '%Y%m%d')::DATE
        AS became_member_on,

    -- Calculate membership tenure in days as of study start date.
    -- Reference date 2018-07-26 was determined by querying MAX(became_member_on)
    -- from the customers table. This represents the latest join date in the
    -- dataset and is used as a proxy for the study start date since no explicit
    -- study start date is provided in the data.
    -- A customer who joined on 2018-07-26 has 0 tenure days.
    -- A customer who joined on 2013-07-29 has approximately 1,822 tenure days.
    -- DuckDB: DATEDIFF('day', date1, date2)
    -- Snowflake equivalent: DATEDIFF(day, date1, date2)
    DATEDIFF('day',
        STRPTIME(CAST(became_member_on AS VARCHAR), '%Y%m%d')::DATE,
        DATE '2018-07-26'
    ) AS membership_tenure_days

FROM customers

-- Exclude invalid records identified in Bronze profiling.
-- All three conditions target the same 2,175 records but are
-- listed independently for clarity and defensive filtering.
WHERE age != 118
  AND income IS NOT NULL
  AND gender IS NOT NULL;