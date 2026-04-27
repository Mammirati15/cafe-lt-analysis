# Gold — Demographic Patterns Results

**Date:** April 26, 2026
**Author:** Matt A.
**Script:** sql/gold/04_gold_demographic_patterns.sql
**Output:** results/demographic_patterns.csv

## Summary
Tier 3 completion rates by demographic segment and offer type.
Minimum 50 offers received per segment applied to filter
statistical noise. Segments below this threshold excluded.

## Key Findings
- Higher income customers ($80k-$100k, $100k+) consistently
  appear at the top of completion rates across both offer types
- Age cohorts 30-44 and 45-59 are the strongest completers
- Lower income brackets show significantly lower completion rates
- Both BOGO and discount offers perform similarly within the
  same demographic segment so offer type matters less than
  who receives it
- "Other" gender customers show high completion rates but
  sample sizes are too small (212 total) to draw reliable
  conclusions

## Recommendations for Café Owner
- Prioritize higher difficulty, higher reward offers for
  $80k+ income segments because they complete at the highest rates
- Age 30-59 is the sweet spot for offer responsiveness
- Consider lower difficulty offers for lower income segments
  to reduce the barrier to completion
- Leverage Salesforce customer records to segment offer
  delivery by income and age

## Notes
- Full results in results/demographic_patterns.csv
- Visualized in Tableau workbook