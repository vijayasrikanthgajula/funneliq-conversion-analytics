# AI Usage & Independent Validation Log

## Overview
AI assistance was used to accelerate SQL query boilerplate drafting, Python verification scripts, and Excel formatting structure during the FunnelIQ capstone project. Every metric, formula, and business claim was independently cross-checked against the raw CSV dataset (`lecture-file.csv`) using Excel PivotTables, SQLite queries, and Python (`pandas`).

---

## Prompts Used & Verification Steps

### 1. Data Quality Audit & Deduplication Rules
- **Prompt Used:** *"Inspect the 5,000-row website event CSV for duplicate event_ids, inconsistent whitespace/casing in traffic_source and marketing_campaign, missing device_type values, and timestamp mismatches."*
- **AI Output:** Identified 25 duplicate `event_id` rows, 22 unstandardized `traffic_source` values with leading spaces/lowercase text, and 35 null `device_type` entries.
- **Independent Validation:**
  - Verified in Excel via **Data > Remove Duplicates** on `event_id` (confirmed exact removal of 25 rows, leaving 4,975 rows).
  - Checked `TRIM()` and `PROPER()` outputs against `UNIQUE()` lists in Excel to confirm exactly 6 clean `traffic_source` values.
  - Cross-referenced the 35 null `device_type` rows by `session_id` using `INDEX/MATCH` in Excel and `groupby('session_id')` in Python; confirmed 29 could be deterministically matched to non-null sibling events in the same session, and 6 single-event sessions were labeled `Unknown`.

### 2. Session-Scoped SQL Funnel Queries
- **Prompt Used:** *"Write SQL queries using DISTINCT session_id denominators to calculate stage progression (session_start, view_item, add_to_cart, begin_checkout, purchase), conversion rates by device_type and traffic_source, and monthly/weekly revenue trends."*
- **AI Output:** Generated CTE-based SQL queries (`WITH session_funnel AS ... GROUP BY session_id`) using `MAX(CASE WHEN event_name = ... THEN 1 ELSE 0 END)` flags.
- **Independent Validation:**
  - Executed all 10 queries in SQLite against the 4,975 cleaned events and compared results against Excel `COUNTIFS` and PivotTable summaries.
  - Confirmed that calculating conversion on **distinct sessions (2,205)** yields **5.26%** (`116 / 2,205`), avoiding the denominator error of dividing by total events (`116 / 4,975 = 2.33%`).
  - Verified that `SUM(purchase_amount_usd)` equals **$27,357.61** across all 116 `purchase` events, with zero revenue values attached to non-purchase events.

### 3. Power BI DAX Measures & Visual Design
- **Prompt Used:** *"Provide DAX measures for Total Sessions, Product View Rate, Add-to-Cart Rate, Purchase Conversion Rate, and Purchase Revenue using distinct session counts."*
- **AI Output:** Supplied `DISTINCTCOUNT(Cleaned_Events[session_id])` and `CALCULATE(..., Cleaned_Events[event_name] = "purchase")` DAX expressions.
- **Independent Validation:**
  - Checked every KPI card and chart breakdown against the SQL output tables (`Desktop = 8.54%`, `Mobile = 4.24%`, `Referral = 6.71%`, `Social = 3.51%`, `September peak = 6.86%`).
