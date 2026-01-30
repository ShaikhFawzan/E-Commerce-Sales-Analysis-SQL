"""
Builds a SQLite database for the Sales Analysis portfolio project.

The script creates the database schema, loads raw sales data from a CSV file,
and generates a cleaned SQL view for analysis. Schema and data-cleaning logic
are kept in external SQL files to maintain modularity and clarity.

Requirements:
    - Python 3.x
    - SQLite (included with Python)
    - online_retail.csv in the project root
    - SQL files located in the /sql directory

The resulting database is used by 03_sales_analysis.sql.
"""

import sqlite3
import csv
import os

# Configuration / File Names
DB_NAME = "sales.db"
CSV_FILE = "online_retail.csv"
# Paths to SQL files
SCHEMA_FILE = "sql/01_schema.sql"
CLEAN_VIEW_FILE = "sql/02_clean_view.sql"

def setup_database():
    """
    Builds the SQLite database, loads CSV data,
    and creates a cleaned view for analysis.
    """
    
    # Connect to the database (creates the file if it doesn't exist)
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    try:
        # Create tables from schema file
        print(f"Reading schema from {SCHEMA_FILE} . . .")
        with open(SCHEMA_FILE, 'r') as f:
            cursor.executescript(f.read())

        # Load CSV data into the sales table
        print(f"Loading data from {CSV_FILE} . . .")    
        if not os.path.exists(CSV_FILE):
            raise FileNotFoundError(f"Ensure {CSV_FILE} is in the root directory.")

        with open(CSV_FILE, newline='', encoding="utf-8") as f:
            reader = csv.DictReader(f)
            
            # List comprehension for efficient data transformation
            rows = [
                (
                    r["InvoiceNo"],
                    r["StockCode"],
                    r["Description"],
                    int(r["Quantity"]),
                    r["InvoiceDate"],
                    float(r["UnitPrice"]),
                    # Handles IDs formatted as floats (e.g., '17850.0') 
                    # and manages missing CustomerIDs as NULLs.
                    int(float(r["CustomerID"])) if r["CustomerID"] else None,
                    r["Country"]
                )
                for r in reader
            ]

        # Bulk insert rather than row by row insertion
        cursor.executemany(
            "INSERT INTO sales VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
            rows
        )
        conn.commit()
        print(f"Successfully imported {len(rows)} records.")

        # Creating a reusable cleaned view for analysis
        print(f"Creating cleaning view from {CLEAN_VIEW_FILE}...")
        with open(CLEAN_VIEW_FILE, 'r') as f:
            cursor.executescript(f.read())

        print("\nDatabase setup complete! You can now run the analysis script.")

    except Exception as e:
        print(f"An error occurred: {e}")
        conn.rollback()
    
    finally:
        conn.close()

if __name__ == "__main__":
    setup_database()