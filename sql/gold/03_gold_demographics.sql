/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Gold
 * Input: silver_customers
 * Output: gold_demographics
 * Purpose: Customer demographic distributions across gender,
 *          age cohort, income bracket, and membership tenure.
 *          Invalid records already excluded in silver_customers.
 * Last Modified: April 26th, 2026
 */

CREATE OR REPLACE VIEW gold_demographics AS

SELECT
    -- Gender distribution
    gender,

    -- Age bucketed into cohorts
    CASE
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 44 THEN '30-44'
        WHEN age BETWEEN 45 AND 59 THEN '45-59'
        WHEN age >= 60 THEN '60+'
    END AS age_cohort,

    -- Income bucketed into brackets
    CASE
        WHEN income < 40000 THEN 'Under $40k'
        WHEN income BETWEEN 40000 AND 59999 THEN '$40k-$60k'
        WHEN income BETWEEN 60000 AND 79999 THEN '$60k-$80k'
        WHEN income BETWEEN 80000 AND 99999 THEN '$80k-$100k'
        WHEN income >= 100000 THEN '$100k+'
    END AS income_bracket,

    -- Membership tenure bucketed
    CASE
        WHEN membership_tenure_days < 365 THEN 'Under 1 year'
        WHEN membership_tenure_days BETWEEN 365 AND 729 THEN '1-2 years'
        WHEN membership_tenure_days BETWEEN 730 AND 1459 THEN '2-4 years'
        WHEN membership_tenure_days >= 1460 THEN '4+ years'
    END AS tenure_cohort,

    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total

FROM silver_customers
GROUP BY gender, age_cohort, income_bracket, tenure_cohort
ORDER BY customer_count DESC;