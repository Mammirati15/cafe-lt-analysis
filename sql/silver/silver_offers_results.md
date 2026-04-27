# Silver Offers — Transformation Results

**Date:** April 26, 2026
**Author:** Matt A.
**Script:** sql/silver/03_silver_offers.sql

## Summary
Cleaned and standardized offers table ready for Gold layer analysis.

## Row Count
- Bronze (raw): 10
- Silver (clean): 10
- No records excluded — all 10 offers are valid

## Transformations Applied
- Parsed channels field from JSON-like list into four boolean flags:
  - is_email, is_mobile, is_social, is_web
- Original channels string retained for reference
- No other transformations required — offers table was clean

## Validation
- All 10 offers present ✓
- Channel flags verified against raw channels string ✓
- Boolean flags correctly reflect channel presence ✓

## Notes
- silver_offers is a VIEW not a table, no data is duplicated
- Snowflake channels parsing uses ARRAY_CONTAINS() with PARSE_JSON()
  DuckDB equivalent uses LIKE string matching — documented inline