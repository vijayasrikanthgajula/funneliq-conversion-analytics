# Power BI Setup & DAX Measures Guide (`FunnelIQ.pbix`)

## 1. Data Model
- **Primary Fact Table:** `Cleaned_Events` (imported from `FunnelIQ_Cleaned_Workbook.xlsx`, 4,975 rows)
- **Session Dimension/Summary Table:** `Session_Summary` (2,205 rows, linked via `session_id` 1-to-Many relationship)

## 2. Core DAX Measures
```dax
Total Sessions = DISTINCTCOUNT(Cleaned_Events[session_id])

Product View Sessions =
CALCULATE(
    DISTINCTCOUNT(Cleaned_Events[session_id]),
    Cleaned_Events[event_name] = "view_item"
)

Product View Rate = DIVIDE([Product View Sessions], [Total Sessions], 0)

Add-to-Cart Sessions =
CALCULATE(
    DISTINCTCOUNT(Cleaned_Events[session_id]),
    Cleaned_Events[event_name] = "add_to_cart"
)

Add-to-Cart Rate = DIVIDE([Add-to-Cart Sessions], [Total Sessions], 0)

Checkout Sessions =
CALCULATE(
    DISTINCTCOUNT(Cleaned_Events[session_id]),
    Cleaned_Events[event_name] = "begin_checkout"
)

Completed Orders =
CALCULATE(
    DISTINCTCOUNT(Cleaned_Events[session_id]),
    Cleaned_Events[event_name] = "purchase"
)

Purchase Conversion Rate = DIVIDE([Completed Orders], [Total Sessions], 0)

Purchase Revenue = SUM(Cleaned_Events[purchase_amount_usd])

Average Order Value = DIVIDE([Purchase Revenue], [Completed Orders], 0)
```
