# Sales Performance & Customer Behavior Analysis

## Overview
This project analyzes sales performance and customer purchasing behavior for a UK-based e-commerce company using SQL. The goal is to answer common business questions related to revenue, customer value, and purchasing patterns while demonstrating clean, maintainable SQL practices (CTEs, window functions, and views) relevant to data analyst roles.

## Objectives
- Calculate core sales metrics (Total Revenue, Average Order Value).
- Identify top-performing countries and high-value customers
- Analyze customer purchasing frequency and ordering behavior
- Demonstrate a modular data pipeline using Python and SQL.

## Dataset
[Online Retail Dataset (2010–2011)](https://www.kaggle.com/datasets/thedevastator/online-retail-sales-and-customer-data).  All credit for the data belongs to Marc Szafraniec.

__Note: Due to file size limits, the raw CSV and database are not stored in this repo. Please follow the setup steps below to generate them or view the notebook `(notebooks/sales_analysis.ipynb).`__

## Reproducibility & Setup

### 1. Download the Dataset
- Download the dataset from the Kaggle link above
- Place the csv file in the root directory.
- Ensure the file is named `online_retail.csv`.

### 2. Initialize the Database (Python)
Run the loading script `(load_csv_to_sqlite)` . This will create `sales.db`, define the schema, and import the data.

### Run from the project root:
Execute the following command:

`python scripts/load_csv_to_sqlite.py`

__Note: The script must be run from the folder containing `online_retail.csv`.__  For simplicity ensure that the csv is in the root (not in any subfolder)

### 3. Run Analysis (SQL)
Run the analysis script to generate insights.

__Mac / Linux / Windows CMD:__
`sqlite3 -column -header sales.db < sql/03_sales_analysis.sql`

__Windows Powershell:__
`Get-Content sql/03_sales_analysis.sql | sqlite3 -column -header sales.db`

### Optional: Interactive Notebook

An interactive Jupyter notebook (`notebooks/sales_analysis.ipynb`) is included
for your convenience in viewing the analysis without needing to download and run SQL scripts.


## Project Structure: 
- `scripts/load_csv_to_sqlite.py`: Data pipeline automation script.
- `sql/01_schema.sql`: Defines the table structure
- `sql/02_clean_view.sql`: Creates a view that contains logic for the data cleaning
- `03_sales_analysis.sql`: Core analytical queries and business logic   


## Key Findings
- Total revenue during the analysis period was approximately __£8.9M__.
- Sales are highly concentrated in the UK, accounting  for __~82%__ of total revenue.
- Revenue peaks in __November 2011__, indicating strong seasonal purchasing behavior heading into the holidays. 
- __Customer Skew:__ while the average customer places ~4 orders, a small subset of users place over 200 orders, which contributes to a disproportionate share of revenue.
- __Retention Opportunity:__ Only __38%__ of customers fall into the VIP/High-Value segments, yet they account for a significant portion of total revenue, this signals a major opportunity to optimize growth through specialized VIP retention strategies.

## Tools & Skills Demonstrated
- SQL (SQLite dialect)
- Data cleaning using SQL views
- Aggregations (SUM, COUNT, AVG)
- `GROUP BY`, `HAVING`, and `JOIN`
- Common Table Expressions (CTEs)
- Basic window functions for comparative analysis
- __Python:__ Data pipeline automation using sqlite3 and csv modules.