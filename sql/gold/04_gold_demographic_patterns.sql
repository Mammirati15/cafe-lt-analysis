/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Gold
 * Input: silver_customers, silver_events, silver_offers
 * Output: gold_demographic_patterns
 * Purpose: Identifies demographic patterns in offer completion.
 *          Shows Tier 3 completion rates by gender, age cohort,
 *          income bracket and offer type. Enables targeted offer
 *          delivery to segments most likely to complete.
 * Known Issues:
 *  Three table join — carefully structured to avoid fan-out.
 *  Tier 3 only — most defensible completion metric.
 *  Informational offers excluded — no completion mechanic.
 *  Minimum 50 offers received per segment to filter statistical noise.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW gold_demographic_patterns AS

WITH

-- Base is every reward offer received with customer demographics
received AS (
    SELECT
        e.customer_id,
        e.offer_id,
        e.time AS received_time,
        o.offer_type,
        o.difficulty,
        o.reward,
        o.duration,
        (o.duration * 24) AS duration_hours,
        -- Customer demographic attributes
        c.gender,
        CASE
            WHEN c.age < 30 THEN 'Under 30'
            WHEN c.age BETWEEN 30 AND 44 THEN '30-44'
            WHEN c.age BETWEEN 45 AND 59 THEN '45-59'
            WHEN c.age >= 60 THEN '60+'
        END AS age_cohort,
        CASE
            WHEN c.income < 40000 THEN 'Under $40k'
            WHEN c.income BETWEEN 40000 AND 59999 THEN '$40k-$60k'
            WHEN c.income BETWEEN 60000 AND 79999 THEN '$60k-$80k'
            WHEN c.income BETWEEN 80000 AND 99999 THEN '$80k-$100k'
            WHEN c.income >= 100000 THEN '$100k+'
        END AS income_bracket
    FROM silver_events e
    INNER JOIN silver_offers o ON e.offer_id = o.offer_id
    INNER JOIN silver_customers c ON e.customer_id = c.customer_id
    WHERE e.event = 'offer received'
      AND o.offer_type IN ('bogo', 'discount')
),

-- Offer viewed events
viewed AS (
    SELECT customer_id, offer_id, time AS viewed_time
    FROM silver_events
    WHERE event = 'offer viewed'
),

-- Offer completed events
completed AS (
    SELECT customer_id, offer_id, time AS completed_time
    FROM silver_events
    WHERE event = 'offer completed'
),

-- Transaction events
transactions AS (
    SELECT customer_id, time AS transaction_time
    FROM silver_events
    WHERE event = 'transaction'
),

-- Join all together
combined AS (
    SELECT
        r.customer_id,
        r.offer_id,
        r.offer_type,
        r.difficulty,
        r.reward,
        r.gender,
        r.age_cohort,
        r.income_bracket,
        r.received_time,
        r.duration_hours,
        v.viewed_time,
        c.completed_time,
        t.transaction_time

    FROM received r

    LEFT JOIN viewed v
        ON r.customer_id = v.customer_id
        AND r.offer_id = v.offer_id

    LEFT JOIN completed c
        ON r.customer_id = c.customer_id
        AND r.offer_id = c.offer_id
        AND c.completed_time >= r.received_time
        AND c.completed_time <= r.received_time + r.duration_hours

    LEFT JOIN transactions t
        ON r.customer_id = t.customer_id
        AND t.transaction_time = c.completed_time
)

-- Final aggregation by demographic segment and offer type
-- Minimum 50 offers received per segment to ensure statistical reliability
SELECT
    gender,
    age_cohort,
    income_bracket,
    offer_type,

    -- Total offers received by this segment
    COUNT(*) AS times_received,

    -- Tier 3 completions is viewed + completed + transaction
    COUNT(CASE WHEN viewed_time IS NOT NULL
               AND completed_time IS NOT NULL
               AND transaction_time IS NOT NULL
               THEN 1 END) AS tier3_completions,

    -- Tier 3 completion rate
    ROUND(COUNT(CASE WHEN viewed_time IS NOT NULL
                     AND completed_time IS NOT NULL
                     AND transaction_time IS NOT NULL
                     THEN 1 END) * 100.0 / COUNT(*), 1)
        AS tier3_rate_pct

FROM combined
GROUP BY gender, age_cohort, income_bracket, offer_type

-- Filter out segments with insufficient sample size
-- Segments below 50 observations produce unreliable completion rates
HAVING COUNT(*) >= 50

ORDER BY tier3_rate_pct DESC;