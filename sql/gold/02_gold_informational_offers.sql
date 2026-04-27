/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Gold
 * Input: silver_events, silver_offers
 * Output: gold_informational_offers
 * Purpose: Measures whether informational offers drove transactions.
 *          Since informational offers have no completion mechanic,
 *          success is defined as a transaction occurring after the
 *          offer was viewed, within the offer duration window.
 *          Note: This is correlation not causation.
 * Known Issues:
 *  Informational offers only, bogo and discount excluded.
 *  Transaction must occur AFTER view, not before.
 *  Duration window enforced manually in hours.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW gold_informational_offers AS

WITH

-- Base: every informational offer received
-- Joined to silver_offers to get duration for window enforcement
received AS (
    SELECT
        e.customer_id,
        e.offer_id,
        e.time AS received_time,
        o.duration,
        (o.duration * 24) AS duration_hours
    FROM silver_events e
    INNER JOIN silver_offers o ON e.offer_id = o.offer_id
    WHERE e.event = 'offer received'
      AND o.offer_type = 'informational'
),

-- Offer viewed events
-- Required because unviewed offers cannot be attributed to behavior change
viewed AS (
    SELECT customer_id, offer_id, time AS viewed_time
    FROM silver_events
    WHERE event = 'offer viewed'
),

-- Transaction events
-- We capture amount to calculate average influenced spend
transactions AS (
    SELECT customer_id, time AS transaction_time, amount
    FROM silver_events
    WHERE event = 'transaction'
),

-- Join all CTEs to base received table
combined AS (
    SELECT
        r.customer_id,
        r.offer_id,
        r.received_time,
        r.duration,
        r.duration_hours,
        v.viewed_time,
        t.transaction_time,
        t.amount

    FROM received r

    -- Must have viewed the offer, unviewed offers not counted
    LEFT JOIN viewed v
        ON r.customer_id = v.customer_id
        AND r.offer_id = v.offer_id

    -- Transaction must occur AFTER view and within duration window
    -- This enforces our proxy metric definition for informational success
    LEFT JOIN transactions t
        ON r.customer_id = t.customer_id
        AND t.transaction_time > v.viewed_time
        AND t.transaction_time <= r.received_time + r.duration_hours
)

-- Final aggregation by offer
-- Joined to silver_offers to include channel flags for analysis
SELECT
    i.offer_id,
    i.duration,

    -- Channel flags from silver_offers
    o.is_email,
    o.is_mobile,
    o.is_social,
    o.is_web,

    -- Volume metrics
    COUNT(*) AS times_received,
    COUNT(i.viewed_time) AS times_viewed,

    -- Influenced transactions = viewed + transaction within window
    COUNT(CASE WHEN i.viewed_time IS NOT NULL
               AND i.transaction_time IS NOT NULL
               THEN 1 END) AS influenced_transactions,

    -- View rate is what % of recipients actually saw the offer
    ROUND(COUNT(i.viewed_time) * 100.0 / COUNT(*), 1)
        AS view_rate_pct,

    -- Influenced rate is what % of recipients transacted after viewing
    ROUND(COUNT(CASE WHEN i.viewed_time IS NOT NULL
                     AND i.transaction_time IS NOT NULL
                     THEN 1 END) * 100.0 / COUNT(*), 1)
        AS influenced_rate_pct,

    -- Average spend for influenced transactions
    ROUND(AVG(CASE WHEN i.viewed_time IS NOT NULL
                   AND i.transaction_time IS NOT NULL
                   THEN i.amount END), 2)
        AS avg_influenced_amount

FROM combined i
-- Join to silver_offers for channel flag data
INNER JOIN silver_offers o ON i.offer_id = o.offer_id
GROUP BY i.offer_id, i.duration, o.is_email, o.is_mobile, o.is_social, o.is_web
ORDER BY influenced_rate_pct DESC;