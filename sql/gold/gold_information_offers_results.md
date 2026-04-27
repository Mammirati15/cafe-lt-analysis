# Gold — Informational Offers Results

**Date:** April 26, 2026
**Author:** Matt A.
**Script:** sql/gold/02_gold_informational_offers.sql
**Output:** results/informational_offers.csv

## Summary
Measures whether informational offers drove transactions. Success
is defined as a transaction occurring after the offer was viewed,
within the offer duration window. This is correlation not causation
— we cannot prove the offer caused the purchase.

## Results
- Offer 1: duration 3 days, social yes, web no, 96.1% view rate,
  67.7% influenced rate, $12.49 avg transaction
- Offer 2: duration 4 days, social no, web yes, 74.6% view rate,
  53.2% influenced rate, $16.44 avg transaction

## Key Findings

- The offer delivered via social media (no web) achieved a 96.1%
  view rate vs 74.6% for the offer delivered via web (no social).
  Social media is the stronger visibility driver.

- Despite lower view rate, the web offer drove higher average
  transaction amounts ($16.44 vs $12.49). Web channel customers
  may have higher spending intent.

- Both offers show meaningful influenced transaction rates (67.7%
  and 53.2%) suggesting informational offers do drive purchase
  behavior when viewed.

## Recommendations for Café Owner
- Include social media in all informational offer channels because
  it drives significantly higher view rates
- Consider testing offers with both social AND web channels
  to capture both high visibility and high spend value
- Informational offers are working so I think they are worth keeping