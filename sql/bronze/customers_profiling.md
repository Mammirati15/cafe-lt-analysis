# Customers Table — Bronze Profiling Results

**Date:** April 26, 2026
**Author:** Matt A.
**Source:** customers_lt.csv

## Row Count
- Total records: 17,000

## Null Analysis
- customer_id: 0 nulls
- age: 0 nulls
- income: 2,175 nulls
- gender: 2,175 nulls
- became_member_on: 0 nulls

## Invalid Record Pattern
The same 2,175 records share all three anomalies: age=118, 
null income, and null gender. This is not random — these are 
the same rows. Data is considered contaminated and unreliable.
Decision: exclude from all Silver layer analysis.

## Age Distribution
- Min: 18 | Max: 118 | Avg: 62.5 (skewed by invalid records)
- Real average will be lower once 2,175 records are excluded

## Income Distribution
- Min: $30,000 | Max: $120,000 | Avg: $65,405

## Gender Distribution
- Male: 8,484
- Female: 6,129
- Other: 212
- None: 2,175 (invalid records — same as above)
- Note: Male majority is unusual for a café loyalty program. 
  Worth investigating in demographic analysis.

## Silver Layer Decisions Driven by This Profiling
- Exclude age=118 / null income / null gender records
- Cast became_member_on from integer to date
- Verify age and income distributions after exclusions