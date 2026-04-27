# Gold — Offer Completion Results

**Date:** April 26, 2026
**Author:** Matt A.
**Script:** sql/gold/01_gold_offer_completion.sql
**Output:** results/offer_completion.csv

## Summary
Three-tier completion rate analysis for all reward offers (bogo and
discount). Each row represents one offer with counts and rates at
each tier of attribution strictness.

## Key Finding — Tier Consistency
Tier 1, Tier 2, and Tier 3 rates are nearly identical across all
offers. This means almost every customer who completed an offer had
viewed it first and had a matching transaction. The unviewed
completion problem is negligible in this dataset. Gross completion
numbers are trustworthy.

## Results
- discount | difficulty $10 | reward $2 | duration 10 days — 76.6% Tier 3
- discount | difficulty $7  | reward $3 | duration 7 days  — 73.2% Tier 3
- bogo     | difficulty $5  | reward $5 | duration 5 days  — 62.0% Tier 3
- bogo     | difficulty $10 | reward $10 | duration 7 days — 51.8% Tier 3
- bogo     | difficulty $10 | reward $10 | duration 5 days — 50.8% Tier 3
- bogo     | difficulty $5  | reward $5 | duration 7 days  — 47.7% Tier 3
- discount | difficulty $10 | reward $2 | duration 7 days  — 47.4% Tier 3
- discount | difficulty $20 | reward $5 | duration 10 days — 30.0% Tier 3

## Key Findings

- Best performer: discount, difficulty $10, reward $2, duration 10 days
  at 76.6% Tier 3 rate. Low difficulty means customers can hit the
  threshold in a single visit.

- Worst performer: discount, difficulty $20, reward $5, duration 10 days
  at 30.0%. The $20 spend threshold is too high for typical café visits.

- Duration impact: Two identical offers (discount, difficulty $10,
  reward $2) differ only in duration — 10 days vs 7 days. The longer
  offer achieves 76.6% vs 47.4%. Three extra days drives a 29 point
  improvement at zero additional cost.

- Discount vs BOGO: Discount offers slightly outperform BOGO overall
  but the difference is not dramatic. Both offer types work.

## Recommendations for Café Owner
- Keep difficulty at $10 or below — $20 is too high
- Extend all offer durations to 10 days minimum
- Discount offers are more cost effective than BOGO at equivalent
  difficulty levels
- The $2 reward on a $10 spend (20% back) is the sweet spot