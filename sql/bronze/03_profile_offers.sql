/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Bronze
 * Input: offers_lt.csv
 * Output: offers_profiling.md
 * Known Issues:
 *  channels field is a JSON-like list requiring parsing in Silver layer.
 *  Informational offers have difficulty=0 and reward=0 by design — not bad data.
 * Last Modified: April 26th, 2026
 */

-- First identify the number of rows for base
SELECT COUNT(*) FROM offers;

-- Null counts per field
SELECT
    COUNT(*) - COUNT(offer_id) as null_offer_id,
    COUNT(*) - COUNT(offer_type) as null_offer_type,
    COUNT(*) - COUNT(difficulty) as null_difficulty,
    COUNT(*) - COUNT(reward) as null_reward,
    COUNT(*) - COUNT(duration) as null_duration,
    COUNT(*) - COUNT(channels) as null_channels
FROM offers;

-- Offer type distribution
SELECT offer_type, COUNT(*) as count
FROM offers
GROUP BY offer_type;

-- Difficulty, reward and duration by offer type
SELECT offer_type, difficulty, reward, duration
FROM offers
ORDER BY offer_type;

-- Channels structure sample
SELECT channels
FROM offers;

--Some Channels don't have web some do
SELECT * FROM offers WHERE channels LIKE '%web%'
SELECT * FROM offers WHERE channels NOT LIKE '%web%'