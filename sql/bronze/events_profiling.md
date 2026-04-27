# Events Table — Bronze Profiling Results

**Date:** April 26, 2026  
**Author:** Matt A.  
**Source:** events_lt.csv  

## Row Count
- Total records: 306,534

## Null Analysis
- No null values found in any field, all columns fully populated

## Duplicate Records
- 396 duplicate rows identified, all in offer completed events
- Same customer_id, event, value, and time logged twice
- Likely caused by double firing in the source event tracking system or in the pipeling producing the provided data
- Decision: deduplicate in Silver layer using ROW_NUMBER() or DISTINCT

## Event Type Distribution
- transaction: 138,953
- offer received: 76,277
- offer viewed: 57,725
- offer completed: 33,579
- Offer completed is roughly 44% of offers received preliminary
  completion rate before applying our three-tier framework
- Note: this ratio includes unviewed completions and duplicates

## Time Range
- Min: 0 hours | Max: 714 hours
- 30 days × 24 hours = 720 hours, this range is consistent with study window

## Value Field Structure
- Two distinct JSON structures depending on event type:
  - Transactions: {'amount': <float>}
  - Offer events: {'offer_id': '<uuid>'}
- Requires parsing in Silver layer before any analysis queries run

## Silver Layer Decisions Driven by This Profiling
- Deduplicate offer completed events
- Parse value field into two clean columns: offer_id and amount
- When joining to customers table, exclude the 2,175 invalid 
  customer records (age=118, null income, null gender). These 
  customers exist in the events table and will contaminate 
  offer completion counts and demographic analysis if not 
  explicitly filtered on every join.