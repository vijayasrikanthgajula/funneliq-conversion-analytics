# FunnelIQ — E-Commerce User Journey & Conversion Analytics

## Project Overview
An end-to-end product and conversion analytics capstone analyzing 5,000 raw e-commerce clickstream event logs (`lecture-file.csv`) recorded between **May 1, 2026 and October 31, 2026**. The objective is to clean raw behavioral tracking records, model distinct session-level conversion funnels in SQL, build an interactive Power BI dashboard, and recommend measurable UX and acquisition improvements.

---

## Repository Structure
```text
funneliq-conversion-analytics/
├── data/
│   ├── raw_events.csv                  # Original 5,000-row website event dataset
│   └── FunnelIQ_Cleaned_Workbook.xlsx  # Cleaned Excel workbook (4,975 events, 2,205 sessions + Cleaning Log)
├── sql/
│   └── funneliq_analysis.sql           # 10 session-scoped SQL queries for funnel, device, channel & revenue metrics
├── dashboard/
│   ├── FunnelIQ_PowerBI_Dashboard_Preview.png  # Exported dashboard layout & KPI snapshot
│   └── DAX_Measures_and_Setup.md       # Power BI data model & DAX formulas for .pbix file
├── report/
│   └── FunnelIQ_Business_Analysis_Report.pdf   # Executive report with 5 key findings & 3 recommendations
├── AI_USAGE.md                         # Documentation of AI prompts and independent data validation
└── README.md                           # Project documentation
```

---

## Data Preparation Summary (Excel)
- **Raw Records:** 5,000 event rows (`2026-05-01` to `2026-10-31`).
- **Deduplication:** Removed **25** exact duplicate `event_id` rows, retaining **4,975** valid events across **2,205** distinct sessions and **1,072** unique visitors.
- **Standardization:** Trimmed trailing spaces and normalized casing across `traffic_source` (22 rows fixed into 6 canonical channels) and `marketing_campaign` (standardized `None` and nulls to `Unattributed`).
- **Missing Value Imputation:** Imputed **29** missing `device_type` entries using matching `session_id` records and labeled the remaining **6** single-event sessions as `Unknown`.

---

## Key KPIs (Session-Level Denominators)
| Metric | Value | Notes |
| :--- | :---: | :--- |
| **Total Website Sessions** | **2,205** | Distinct `session_id` count |
| **Product View Rate** | **82.81%** | 1,826 sessions reached `view_item` |
| **Add-to-Cart Rate** | **25.62%** | 565 sessions reached `add_to_cart` |
| **Checkout Initiation Rate** | **11.93%** | 263 sessions reached `begin_checkout` |
| **Purchase Conversion Rate** | **5.26%** | 116 completed orders (`purchase`) |
| **Total Purchase Revenue** | **$27,357.61** | Average Order Value (AOV): **$235.84** |

---

## Key Findings & Recommendations
1. **Overall Conversion:** **5.26%** of distinct sessions (116 of 2,205) result in a completed purchase, generating **$27,357.61** in revenue.
2. **Primary Funnel Bottleneck:** The steepest drop-off occurs between **Product View (`view_item`) and Add to Cart (`add_to_cart`)**, where **69.06%** of product viewers (1,261 of 1,826 sessions) exit without adding an item to their cart. A secondary drop-off of **55.89%** occurs between Checkout Initiation and Purchase (147 abandoned checkouts).
3. **Device Performance Gap:** **Desktop** delivers the highest conversion rate at **8.54%** (45 orders / 527 sessions)—more than double **Mobile's 4.24%** (66 orders / 1,556 sessions), even though Mobile drives **70.57%** of total traffic.
4. **Traffic Source Quality:** **Referral** (**6.71%**, $288.71 AOV) and **Organic Search** (**5.91%**, $7,190.11 revenue) convert best, whereas **Social** converts at just **3.51%** (12 orders / 342 sessions) due to a 34.21% landing-page bounce before viewing a product.
5. **Actionable Experiments:**
   - **Mobile Product Page & Sticky CTA Redesign:** Target Mobile `view_item -> add_to_cart` rate to lift mobile conversion from 4.24% toward 6.0%.
   - **Guest Checkout & Express Wallets (Apple Pay / Google Pay):** Reduce the 55.89% checkout abandonment rate.
   - **Social Landing Page Alignment & Retargeting:** Route Social traffic directly to curated category/product pages rather than generic landing pages.
