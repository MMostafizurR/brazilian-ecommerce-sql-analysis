# Brazilian E-Commerce Operations & Customer Experience Analysis

An end-to-end analytics project leveraging **T-SQL (SQL Server)** to dissect delivery logistics, commercial operations, and customer satisfaction metrics using the Olist dataset. The project transitions from foundational data aggregations to complex analytical architectures, utilizing advanced subqueries, conditional formatting, window functions, and seasonal baselines.

---

## 📊 Dataset Context
The project utilizes the public **Brazilian E-Commerce Dataset by Olist**, which contains information on 100k orders from 2016 to 2018 made across multiple marketplaces in Brazil. 
* **Source:** [Kaggle - Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data)

---

## 🔍 Key Business Problems Addressed
1. **Demographic Footprint:** Mapping customer density variations by geographic state and city.
2. **Operational Load:** Quantifying daily purchase volume fluctuations to identify supply chain peak loads.
3. **Category Profitability & Financial Gap:** Evaluating the pricing spread across retail categories against actual payment volumes.
4. **Logistics Performance vs. Customer Sentiment:** Formulating strict time-delta calculation boundaries to measure how delivery delays directly propagate into low review scores (1-5 stars).
5. **Macro Seasonality vs. Micro Exceptions:** Segmenting historical monthly shipping trends to isolate individual transactional outliers that underperformed against the seasonal standard.

---

## 🛠️ SQL Engineering Highlights

This project demonstrates proficiency across a wide spectrum of relational database engineering concepts:

### 1. Data Aggregation & Conditional Logic
* **Metrics Compiling:** Consolidates pricing data and review scores concurrently while routing rating distribution counts into clear tabular matrixes using conditional `CASE WHEN` flags.
* **Anomaly Identification:** Isolates established, high-revenue categories suffering from systemic logistics friction via programmatic `HAVING` filters.

### 2. Time-Series & Modular Architectures
* **Stored Procedures:** Features dynamic parameter filtering (`@StartdateDesc`, `@EnddateDesc`) wrapping automated date parsing logic to return structural operational volumes inside specified testing parameters.
* **Date Manipulation:** Standardizes heterogeneous timestamp structures across system tables using strict `CAST` transformations and microsecond-accurate time-boundary mappings (`DATEDIFF`).

### 3. Advanced Analytical Window Functions & Joins
* **Seasonal Baselines:** Implements an advanced script utilizing independent grouping blocks combined via `LEFT JOIN` on matching calendar expressions. This isolates a specific calendar month's baseline trend across multi-year cycles to highlight macro business shifts.
* **Nested Subquery Exception Reports:** Orchestrates a three-tier layered analysis executing an analytical Window Function (`AVG(...) OVER (PARTITION BY ...)`) to track localized performance thresholds, filtering individual rows dynamically to flag explicit shipping delays that dropped below the current monthly mean.

---

## 📁 Repository Structure
```text
├── Data/
│   └── README.md              # Documentation linking to raw Kaggle datasets
├── Scripts/
│   └── SQL Data Analysis Project eCommerce Site.sql  # Complete compilation of production T-SQL scripts
└── README.md                  # Executive summary and technical documentation

---

## 📈 Key Query Samples & Target Outputs

Here are a few high-impact analysis scripts from the project along with sample outputs demonstrating the database schema capabilities.

### 1. Advanced Product Performance & Sentiment Matrix
This script compiles total revenues and order volumes per category while simultaneously mapping the exact breakdown of customer review scores (1 to 5 stars) to identify quality issues.

```sql
SELECT
    pd.product_category_name,
    SUM(oid.price) AS Total_Revenue,
    COUNT(oid.order_id) AS Total_Orders,
    AVG(ord.review_score) AS Avg_Score,
    COUNT(CASE WHEN ord.review_score = 1 THEN 1 END) AS Total_1_Star_Reviews,
    COUNT(CASE WHEN ord.review_score = 5 THEN 1 END) AS Total_5_Star_Reviews
FROM
    olist_order_items_dataset$ oid
JOIN olist_products_dataset$ pd ON oid.product_id = pd.product_id
JOIN olist_order_reviews_dataset$ ord ON oid.order_id = ord.order_id
GROUP BY
    pd.product_category_name
ORDER BY
    Total_Revenue DESC;

| product_category_name | Total_Revenue | Total_Orders | Avg_Score | Total_1_Star_Reviews | Total_5_Star_Reviews |
| :---                  | ---:          | ---:         | ---:      | ---:                 | ---:                 |
| relogios_presentes    | 210880.14     | 1144         | 4.07      | 103                  | 624                  |
| cama_mesa_banho       | 171322.72     | 1897         | 3.81      | 298                  | 951                  |
| beleza_saude          | 164494.91     | 1403         | 4.18      | 142                  | 872                  |
| esporte_lazer         | 154977.43     | 1349         | 4.02      | 182                  | 782                  |        


This query utilizes a T-SQL Window Function (AVG(...) OVER()) to calculate historical monthly benchmarks, dynamically matching them against individual orders to flag shipments that performed worse than the monthly average.

```sql
SELECT order_id, order_year, order_month, date_diff, avg_month_diff
FROM (
    SELECT
        order_id,
        YEAR(CAST(order_purchase_timestamp AS datetime)) AS order_year,
        MONTH(CAST(order_purchase_timestamp AS datetime)) AS order_month,
        DATEDIFF(day, CAST(order_delivered_customer_date AS datetime), CAST(order_estimated_delivery_date AS datetime)) AS date_diff,
        AVG(CAST(DATEDIFF(day, CAST(order_delivered_customer_date AS datetime), CAST(order_estimated_delivery_date AS datetime)) AS float)) 
            OVER (PARTITION BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)) AS avg_month_diff
    FROM olist_orders_dataset$
    WHERE order_status = 'delivered' AND order_delivered_customer_date <> ''
) s
WHERE date_diff < avg_month_diff
ORDER BY order_year, order_month;
