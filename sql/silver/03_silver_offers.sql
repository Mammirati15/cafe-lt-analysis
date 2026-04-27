/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Silver
 * Input: offers table (Bronze)
 * Output: silver_offers view
 * Purpose: Clean and standardize offers table for analysis.
 *          Parses channels from JSON-like list into individual
 *          boolean flags for clean filtering in Gold layer.
 * Known Issues:
 *  channels field is a JSON-like list using single quotes.
 *  Parsed into individual boolean flags: is_email, is_mobile,
 *  is_social, is_web.
 *  Informational offers have difficulty=0 and reward=0 by design.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW silver_offers AS
SELECT
    offer_id,
    offer_type,
    difficulty,
    reward,
    duration,

    -- Parse channels list into individual boolean flags.
    -- Raw format: ['email', 'mobile', 'social'] (single quoted list)
    -- We use LIKE to check if each channel name appears in the string.
    -- DuckDB: channels LIKE '%email%'
    -- Snowflake equivalent: ARRAY_CONTAINS('email'::VARIANT, PARSE_JSON(channels))
    CASE WHEN channels LIKE '%email%'  THEN true ELSE false END AS is_email,
    CASE WHEN channels LIKE '%mobile%' THEN true ELSE false END AS is_mobile,
    CASE WHEN channels LIKE '%social%' THEN true ELSE false END AS is_social,
    CASE WHEN channels LIKE '%web%'    THEN true ELSE false END AS is_web,

    -- Keep original channels string for reference
    channels

FROM offers;