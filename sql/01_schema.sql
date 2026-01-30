-- Initializing the raw sales table
-- This schema reflects the structure of the Online Retail Dataset from Kaggle
DROP TABLE IF EXISTS sales;

CREATE TABLE IF NOT EXISTS sales (
    InvoiceNo   TEXT,    -- Unique identifier for the transaction
    StockCode   TEXT,    -- Item code
    Description TEXT,    -- Product name
    Quantity    INTEGER, -- Number of units purchased
    InvoiceDate TEXT,    -- Raw date string
    UnitPrice   REAL,    -- Price per unit in GBP
    CustomerID  INTEGER, -- Unique customer ID
    Country     TEXT     -- Customer's country of residence
);