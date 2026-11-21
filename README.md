# 🛒 End-To-End E-Commerce Sales & Performance Analytics

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Power Query](https://img.shields.io/badge/Power%20Query-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)

## 📌 Project Overview
An end-to-end interactive Business Intelligence project analyzing e-commerce sales performance across **Nov 2025 – Apr 2026**, tracking net revenue, Average Order Value (**AOV**), order volume, unit sales, customer base, and product/category return rates. Starting from raw transactional data explored in **SQL** and cleaned in **Power Query** into a single-direction **Star Schema**, the solution combines **DAX** measures with an interactive **Power BI** dashboard styled with a clean dual-tone palette (**Charcoal/Grey** for `2025` and **Blue** for `2026`).

![E-Commerce Sales & Performance Dashboard](E-Commerce%20Sales%20Performance%20Analytics.png)

## 🔗 Live Interactive Dashboard

[View the Live Dashboard Here](https://app.powerbi.com/view?r=eyJrIjoiN2FmMWVhNGEtOTg4Yy00MmI5LTk0YjctODQ4MWFkNzE2MzhkIiwidCI6IjJiYjZlNWJjLWMxMDktNDdmYi05NDMzLWMxYzZmNGZhMzNmZiIsImMiOjl9)

---

## 📋 Dataset Scope & Coverage
> **Data Overview:** This dataset contains e-commerce order-level records spanning **Nov–Dec 2025** and **Jan–Apr 2026**, enabling cross-period revenue tracking, monthly trend analysis, return rate diagnostics across all product categories, and SKU-level performance evaluation.

### **Included Data Attributes:**
- **Time & Calendar Dimensions:** Standardized order dates mapped to a dedicated calendar table (`dim_date`) covering *Year, Quarter, and Month* for accurate chronological analysis and Year-to-Date (`Sales YTD`) tracking.
- **Product & Category Hierarchy:** Product names/SKUs and all six categories (*Electronics, Apparel, Home, Sports, Toys, Beauty*) linked through `dim_products`.
- **Customer, Segment & Order Records:** Order identifiers, customer segments and counts (`dim_customers`), quantities sold, gross sales (`Total Sales`), net revenue (`Net Sales`), Average Order Value (`AOV`), and return indicators (`fact_orders`).

---

## 🧹 Data Cleaning & Transformation (SQL & Power Query)
Raw e-commerce records were audited and prepared before building the semantic model:
- **SQL Exploration & Metric Validation:** Queried raw transactional data in `ecommerce_orders.sql` to verify date coverage (`2025–2026`), order counts, pricing/quantity fields, segment/category standardization, and return behavior prior to reporting.
- **Mixed Date Format Resolution (Power Query):** Resolved inconsistent date formats (`YYYY-MM-DD`, `DD/MM/YYYY`, and `MM/DD/YYYY`) by grouping records by `order_id` to propagate valid order dates across multi-line orders without fabricating missing dates.
- **Transparent Handling of Missing Order Dates:** Preserved orders lacking raw dates in headline KPI totals (`$233.12K` Net Sales) while excluding `$25.31K` (`10.86%`) from time-based visuals (`Net Sales by Quarter` showing `$207.81K`) with clear dashboard annotation.
- **Star Schema Normalization:** Restructured the data in **Power Query** into a clean **Star Schema** comprising `fact_orders` connected via one-to-many (`1:*`) single-direction relationships to `dim_date`, `dim_products`, and `dim_customers`.

![Data Model](Data%20model.png)

---

## 📐 DAX Modeling & Visualization (Power BI)
1. **DAX Measures & KPIs:**
  - Built core KPI measures including `Net Sales` (`$233.12K`), `AOV` (`$88.34`), `Total Orders` (`2.8K`), `Total Qty Sold` (`6.93K`), `Num of Customers` (`539`), and `Return Rate` (`5.76%`).
  - Implemented `Sales YTD` alongside yearly performance metrics to track **2025** (`$69,970.50` across `838` dated orders) and **2026** (`$120,481.09` across `1,457` dated orders).
2. **Executive Dashboard Design:**
  - Structured the canvas with 6 logically ordered KPI cards (`Net Sales`, `AOV`, `Total Orders`, `Total Qty Sold`, `Num of Customers`, `Return Rate`), a monthly trend area chart (`Total Sales by Year and Month`), full-category sales and return rate visuals, a quarterly donut chart (`Net Sales by Quarter`), a top-products table, and a yearly summary table.
  - Integrated five interactive slicers (*Segment, Category, Year, Month, and Quarter*) for multi-dimensional slicing.

---

## 📊 Key Insights
| Metric / Dimension | Key Finding |
| :--- | :--- |
| **Overall Performance** | Net Sales reached **$233.12K** at an **$88.34 AOV** across **2.8K** orders (**6.93K** units sold) and **539** customers, with a **5.76%** overall return rate. |
| **Monthly & Period Trajectory** | Sales peaked in **Dec 2025 ($65.86K)** following **Nov 2025 ($14.84K)**, while **2026** grew steadily from **Jan ($32.59K)** and **Feb ($35.74K)** to a **Mar peak ($43.74K)** before **Apr ($27.71K)**. |
| **Quarterly Concentration** | Among dated orders (**$207.81K**), **Q1** accounts for **50.73%** of net sales, **Q4** contributes **36.59%**, and **Q2** represents **12.67%**. |
| **Category Sales Ranking** | **Electronics** leads net sales at **$75K**, followed by **Apparel ($56K)**, **Home ($35K)**, **Sports ($27K)**, **Toys ($21K)**, and **Beauty ($19K)**. |
| **Return Rate & Top SKUs** | **Toys (7.88%)** and **Sports (6.59%)** record the highest category return rates while **Beauty** maintains the lowest (**3.71%**); **Phone Case** has an **8.27%** return rate, whereas **Wireless Earbuds** leads product net sales at **$14,355.58** (**4.56%** return rate). |

---

## 📂 Repository Structure
- `ecommerce_orders.pbix` — Interactive Power BI Desktop report file including Star Schema model, DAX measures, and visuals.
- `ecommerce_orders.csv` — E-commerce order-level dataset.
- `ecommerce_orders.sql` — SQL queries for exploration and validation.
- `E-Commerce Sales Performance Analytics.png` — High-resolution export of the final dashboard.
- `Data model.png` — Screenshot of the single-direction Star Schema data model.

---

## 👤 Author
**Yahia Farag** — Data Analyst  
*Tools: Power BI · Power Query · DAX · SQL*
