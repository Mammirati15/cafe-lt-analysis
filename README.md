# Cafe LT Rewards — Loyalty Program Analysis

Author: Matt A.
Date: April 2026
Type: Data Engineer Take-Home Analysis

## Overview
Analysis of 30 days of Cafe LT Rewards loyalty program data covering offer completion rates, informational offer attribution, customer demographics, and demographic patterns in offer response.

Built using a medallion architecture (Bronze/Silver/Gold) for clean, auditable, and flexible data transformation. Queries written with Snowflake consideration but executed locally via DuckDB.

## Project Structure
bronze — raw source data (xlsx and csv)
docs — project documentation and reasoning log
sql/bronze — data profiling scripts
sql/silver — cleaning and standardization
sql/gold — analytical models
results — CSV outputs and findings
presentation — final slide deck
tableau — Tableau workbook
setup_db.py — DuckDB database setup script

## Tech Stack
SQL and DuckDB for query execution with Snowflake-compatible syntax
Python for DuckDB interface and CSV export
Tableau for visualization
Git and GitHub for version control

## Data Sources
Four Excel files simulating 30 days of cafe loyalty activity:
customers.xlsx: 17,000 customer records
events.xlsx: 306,534 event rows
offers.xlsx: 10 offer configurations
data_dictionary.xlsx: field definitions

## Architecture

Bronze layer preserves raw source data exactly as received. Profiling scripts document row counts, null values, duplicates, and data quality issues. Nothing is modified at this layer.

Silver layer handles cleaning and standardization. Key transformations include excluding 2,175 invalid customer records, deduplicating 396 duplicate offer completed events, parsing the JSON like value field into offer_id and amount columns, casting became_member_on from integer to proper date, and parsing the channels field into boolean flags.

Gold layer contains analytical models built on the clean Silver layer. One model per business question.
01_gold_offer_completion offers three tier completion rate framework
02_gold_informational_offers is transaction attribution for informational offers
03_gold_demographics is customer demographic distributions
04_gold_demographic_patterns is completion rates and uses by demographic segment

## Key Findings
Best performing offer is a discount at $10 difficulty, $2 reward, 10 day duration with a 76.6% Tier 3 completion rate. Extending offer duration from 7 to 10 days drives a 29 point improvement at zero cost. Social media drives significantly higher view rates for informational offers. Higher income customers complete offers at meaningfully higher rates. Tier 1, 2, and 3 completion rates are nearly identical confirming completions are genuine behavioral responses.

## Setup
pip3 install duckdb
python3 setup_db.py

## Documentation
Full reasoning log, data quality decisions, and analytical framework documented in docs/Reasoning_Log.docx.