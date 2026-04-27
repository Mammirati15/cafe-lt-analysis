# Silver Events — Transformation Results

**Date:** April 26, 2026
**Author:** Matt A.
**Script:** sql/silver/02_silver_events.sql

## Summary
Cleaned and standardized events table ready for Gold layer analysis.

## Row Count
- Bronze (raw): 306,534
- Silver (clean): 272,388
- Removed: 34,146 rows total
  - 396 duplicate offer completed events
  - ~33,750 events belonging to 2,175 invalid customers

## Event Type Distribution in Silver
- transaction: 123,957
- offer received: 66,501
- offer viewed: 49,860
- offer completed: 32,070

## Transformations Applied
- Deduplicated 396 offer completed events using ROW_NUMBER() 
  OVER (PARTITION BY customer_id, event, value, time)
- Parsed value field from JSON-like string into two clean columns:
  - offer_id: populated for offer events, NULL for transactions
  - amount: populated for transactions, NULL for offer events
- Fixed JSON parsing issue — raw value field uses single quotes 
  and 'offer id' with a space instead of standard JSON format.
  Normalized before extraction using string replacement.
- Excluded events from 2,175 invalid customers via INNER JOIN 
  to silver_customers

## Validation
- null_offer_id count (123,957) matches transaction count (123,957) ✓
- null_amount count (148,431) matches non-transaction count (148,431) ✓
- Deduplication confirmed, no duplicate rows remain ✓

## Notes
- silver_events is a VIEW not a table so no data is duplicated
- Snowflake syntax differences documented inline in the SQL script
- value field parsing uses json_extract_string in DuckDB
  Snowflake equivalent: PARSE_JSON(value):offer_id::STRING