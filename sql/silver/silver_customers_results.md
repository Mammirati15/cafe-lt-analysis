# Silver Customers — Transformation Results

**Date:** April 26, 2026
**Author:** Matt A.
**Script:** sql/silver/01_silver_customers.sql

## Summary
Cleaned and standardized customers table ready for Gold layer analysis.

## Row Count
- Bronze (raw): 17,000
- Silver (clean): 14,825
- Excluded: 2,175 records (age=118, null income, null gender)

## Transformations Applied
- Excluded 2,175 invalid records identified in Bronze profiling
- Cast became_member_on from integer (yyyymmdd) to proper DATE type
- Added membership_tenure_days which is days between join date and study
  start date (2018-07-26). Reference date derived from 
  MAX(became_member_on) in the customers table.

## Validation
- Expected exclusions: 2,175 ✓
- Row count confirmed: 14,825 ✓
- Date format confirmed: yyyy-mm-dd ✓
- Tenure days calculating based on Max created on date

## Notes
- silver_customers is a VIEW not a table so no data is duplicated
- Snowflake syntax differences documented inline in the SQL script