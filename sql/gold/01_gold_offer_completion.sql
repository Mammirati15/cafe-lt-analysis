/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Gold
 * Input: silver_events, silver_offers
 * Output: gold_offer_completion
 * Purpose: Three-tier offer completion rates for reward offers.
 *          Tier 1: gross completions, Tier 2: attributed (completion
 *          + transaction same timestamp), Tier 3: truly effective
 *          (viewed + completion + transaction same timestamp).
 * Known Issues:
 *  Informational offers excluded — no completion mechanic exists.
 *  Duration window enforced manually — not assumed pre-enforced.
 *  DuckDB: ROUND(), LEFT JOIN syntax same as Snowflake.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW gold_offer_completion AS

WITH

-- Base is every reward offer received, joined to offers for metadata
received AS (
    SELECT
        e.customer_id,
        e.offer_id,
        e.time AS received_time,
        o.offer_type,
        o.difficulty,
        o.reward,
        o.duration,
        (o.duration * 24) AS duration_hours
    FROM silver_events e
    INNER JOIN silver_offers o ON e.offer_id = o.offer_id
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
    SELECT customer_id, time AS transaction_time, amount
    FROM silver_events
    WHERE event = 'transaction'
),

-- Join all CTEs together against the base received table
combined AS (
    SELECT
        r.customer_id,
        r.offer_id,
        r.offer_type,
        r.difficulty,
        r.reward,
        r.duration,
        r.received_time,
        r.duration_hours,

        -- Did they view it?
        v.viewed_time,

        -- Did they complete it within the duration window?
        c.completed_time,

        -- Was there a transaction at the same time as completion?
        t.transaction_time,
        t.amount

    FROM received r

    -- LEFT JOIN viewed so not every offer gets viewed
    LEFT JOIN viewed v
        ON r.customer_id = v.customer_id
        AND r.offer_id = v.offer_id

    -- LEFT JOIN completed to enforce duration window here
    -- completion must occur after receipt and within duration
    LEFT JOIN completed c
        ON r.customer_id = c.customer_id
        AND r.offer_id = c.offer_id
        AND c.completed_time >= r.received_time
        AND c.completed_time <= r.received_time + r.duration_hours

    -- LEFT JOIN transaction — must match completion timestamp exactly
    -- this is the case description's definition of attribution
    LEFT JOIN transactions t
        ON r.customer_id = t.customer_id
        AND t.transaction_time = c.completed_time
)

-- Final aggregation by offer
SELECT
    offer_id,
    offer_type,
    difficulty,
    reward,
    duration,

    -- Total times this offer was received (denominator)
    COUNT(*) AS times_received,

    -- Tier 1: gross completions
    COUNT(completed_time) AS tier1_completions,

    -- Tier 2: completion with matching transaction
    COUNT(CASE WHEN completed_time IS NOT NULL
               AND transaction_time IS NOT NULL
               THEN 1 END) AS tier2_completions,

    -- Tier 3: viewed + completion + matching transaction
    COUNT(CASE WHEN viewed_time IS NOT NULL
               AND completed_time IS NOT NULL
               AND transaction_time IS NOT NULL
               THEN 1 END) AS tier3_completions,

    -- Completion rates as percentages
    ROUND(COUNT(completed_time) * 100.0 / COUNT(*), 1)
        AS tier1_rate_pct,

    ROUND(COUNT(CASE WHEN completed_time IS NOT NULL
                     AND transaction_time IS NOT NULL
                     THEN 1 END) * 100.0 / COUNT(*), 1)
        AS tier2_rate_pct,

    ROUND(COUNT(CASE WHEN viewed_time IS NOT NULL
                     AND completed_time IS NOT NULL
                     AND transaction_time IS NOT NULL
                     THEN 1 END) * 100.0 / COUNT(*), 1)
        AS tier3_rate_pct

FROM combined
GROUP BY offer_id, offer_type, difficulty, reward, duration
ORDER BY tier3_rate_pct DESC;