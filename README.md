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
