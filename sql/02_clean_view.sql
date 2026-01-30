/* =============================================================================
   DATA CLEANING LAYER
   -----------------------------------------------------------------------------
   Create a reusable clean view to enforce consistent data quality across
   all analyses.
   ============================================================================= */

-- Clean up existing view to allow for a fresh run
DROP VIEW IF EXISTS clean_sales;

CREATE VIEW clean_sales AS
SELECT
  InvoiceNo,
  InvoiceDate,
  CustomerID,
  Country,
  Quantity,
  UnitPrice,
  (Quantity * UnitPrice) AS sales_value
FROM sales
WHERE
-- Exclude cancelled invoices (start with 'C')
  InvoiceNo NOT LIKE 'C%'
-- Ensure valid transaction values
  AND Quantity > 0
  AND UnitPrice > 0
  -- Keep only identifiable customers
  AND CustomerID IS NOT NULL;