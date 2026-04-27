# Offers Table — Bronze Profiling Results

**Date:** April 26, 2026  
**Author:** Matt A.  
**Source:** offers_lt.csv  

## Field Definitions
- difficulty: minimum dollar amount customer must spend to complete the offer
- reward: dollar value returned to customer upon completion
- duration: number of days customer has to redeem the offer
- channels: marketing channels used to deliver the offer

## Row Count
- Total records: 10
- 4 BOGO, 4 discount, 2 informational

## Null Analysis
- No null values found in any field — all columns fully populated

## Offer Type Breakdown
- BOGO (4 offers): difficulty and reward are always equal, makes sense for buy one get one
- Discount (4 offers): reward is approximately 20% of difficulty,
  a standard discount structure
- Informational (2 offers): difficulty=0 and reward=0 by design because
  these are advertisements, not incentive offers

## Channel Analysis
- 8 of 10 offers include web as a channel
- 2 offers (1 BOGO, 1 informational) delivered via email, mobile, 
  and social only, no web
- Insufficient data to determine if intentional targeting or 
  configuration oversight

## Silver Layer Decisions Driven by This Profiling
- Parse channels field from JSON-like string into individual 
  channel flags (is_email, is_mobile, is_social, is_web) for 
  clean filtering in Gold layer analysis
- No records to exclude, all 10 offers are valid