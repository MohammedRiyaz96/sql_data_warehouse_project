/*
===============================================================================================================
Quality Checks: Perform Validations to Test the Quality of Report Layer.
===============================================================================================================
Script Purpose:
	This script performs quality checks for data consistency, accuracy and integrity across 'report' schema. 
	It includes checks for:
	- Uniqueness of surrogate keys in dimensions.
	- Referential integrity between fact and dimension tables.
	- Validation of relationships in the data model for analytical purpose.

Note:
	- Run these tests after loading data into Report layer.
	- Investigate and resolve any discrepancies found during the tests.
===============================================================================================================
*/

--------------------------------------- DIM_CUSTOMERS ---------------------------------------------------
-- Check for Nulls or Duplicates in Primary Key Column.
SELECT customer_id, COUNT(*)
FROM report.dim_customers
GROUP BY customer_id
	HAVING COUNT(*) > 1 OR customer_id IS NULL;


-- Data Validation, Consistency & Handling Missing Values.
-- Action: Validate Correct Data and Replace Nulls with Default Values.
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE 
		WHEN ci.cst_gndr = 'NA' THEN COALESCE(ca.gen, 'NA')
		ELSE ci.cst_gndr
		END AS new_gen
FROM stage.crm_cust_info ci
LEFT JOIN stage.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN stage.erp_loc_a101 la
	ON ci.cst_key = la.cid
ORDER BY 1,2


-- Data Standardization, Consistency & Handling Missing Values.
SELECT DISTINCT gender FROM report.dim_customers;

SELECT * FROM report.dim_customers;

--------------------------------------- DIM_PRODUCTS ---------------------------------------------------
-- Check for Nulls or Duplicates in Primary Key Column.
SELECT product_key, COUNT(*)
FROM report.dim_products
GROUP BY product_key
	HAVING COUNT(*) > 1 OR product_key IS NULL;

SELECT * FROM report.dim_products;

--------------------------------------------------------------------------------------------------------

-- Foreign Key Integrity Check (check the data model connectivity between fact and dimensions).
SELECT * 
FROM report.fact_sales s
LEFT JOIN report.dim_customers c
	ON s.customer_key = c.customer_key
LEFT JOIN report.dim_products p
	ON s.product_key = p.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
