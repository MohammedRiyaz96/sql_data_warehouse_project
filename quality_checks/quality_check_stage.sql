/*
===============================================================================================================
Quality Checks: Perform Validations to Test the Quality of Stage Layer.
===============================================================================================================
Script Purpose:
	This script performs various quality checks for data consistency, accuracy and standardization across
	'stage' schema. It includes checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields.
	- Data standardization and consistency.
	- Invalid date range and orders.
	- Data consistency between related fields.

Note:
	- Run these tests after loading data into Stage layer.
	- Investigate and resolve any discrepancies found during the tests.
===============================================================================================================
*/

--------------------------------------- CRM_CUST_INFO ---------------------------------------------------
-- Check for Nulls or Duplicates in Primary Key Column.
-- Action: Remove Duplicates or Nulls.
SELECT cst_id, COUNT(*)
FROM stage.crm_cust_info
GROUP BY cst_id
	HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for Unwanted Spaces.
-- Action: Trim Unwanted Spaces.
SELECT cst_lastname
FROM stage.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- Data Standardization, Consistency & Handling Missing Values.
-- Action: Standardize Coded Values to Readable Format and Replace Nulls with Default Values.
SELECT DISTINCT cst_marital_status
FROM stage.crm_cust_info;


SELECT * FROM stage.crm_cust_info;

--------------------------------------- CRM_PRD_INFO ---------------------------------------------------

-- Check for Nulls or Duplicates in Primary Key Column.
-- Action: Remove Duplicates or Nulls.
SELECT prd_id, COUNT(*)
FROM stage.crm_prd_info
GROUP BY prd_id
	HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Check for Unwanted Spaces.
-- Action: Trim Unwanted Spaces.
SELECT prd_nm
FROM stage.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for Negative Numbers & Handle Missing Values.
-- Action: Change it to Positive Value (abs) and Replace Nulls with Defaults.
SELECT prd_cost
FROM stage.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization, Consistency & Handling Missing Values.
-- Action: Standardize Coded Values to Readable Format and Replace Nulls with Default Values.
SELECT DISTINCT prd_line
FROM stage.crm_prd_info;


-- Check for Invalid Order of Dates.
/* Action: Find a Solution that End Date Must be Greater than Start Date and Overlapping Should be Avoided.
Get an Approval with the Source Team post Finding a Solution. */
SELECT *
FROM stage.crm_prd_info
WHERE prd_start_dt > prd_end_dt


SELECT * FROM stage.crm_prd_info;

--------------------------------------- CRM_SALES_DETAILS ---------------------------------------------------

-- Check for Unwanted Spaces.
-- Action: Trim Unwanted Spaces.
SELECT sls_ord_num
FROM stage.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- Check for Invalid Dates.
-- Action: Replace Invalid Dates with Nulls.
SELECT sls_due_dt
FROM stage.crm_sales_details
WHERE sls_due_dt <= 0 
	  OR LEN(sls_due_dt) != 8
	  OR sls_due_dt > 20500101
	  OR sls_due_dt < 19000101;


-- Check for Invalid Order of Dates.
/* Action: Find a Solution that End Date Must be Greater than Start Date and Overlapping Should be Avoided.
Get an Approval with the Source Team post Finding a Solution. */
SELECT *
FROM stage.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


-- Check Data Consistency Between Sales, Quantity and Price.
-- Rules: 1. Sales = Quantity * Price | 2. Values Must Not be Null, Negative or Zero.
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM stage.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;


SELECT * FROM stage.crm_sales_details;

--------------------------------------- ERP_CUST_AZ12 ---------------------------------------------------

-- Identify Out of Range Dates.
-- Action: Replace them with Nulls.
SELECT bdate
FROM stage.erp_cust_az12
WHERE bdate > GETDATE();


-- Data Standardization, Consistency & Handling Missing Values.
-- Action: Standardize Coded Values to Readable Format and Replace Nulls with Default Values.
SELECT DISTINCT gen 
FROM stage.erp_cust_az12;


SELECT * FROM stage.erp_cust_az12;

--------------------------------------- ERP_LOC_a101 ---------------------------------------------------

-- Data Standardization, Consistency & Handling Missing Values.
-- Action: Standardize Coded Values to Readable Format and Replace Nulls with Default Values.
SELECT 
	DISTINCT cntry
FROM stage.erp_loc_a101;

SELECT * FROM stage.erp_loc_a101;

--------------------------------------- ERP_PX_CAT_G1V2 ---------------------------------------------------


-- Data Standardization, Consistency & Handling Missing Values.
-- Action: Standardize Coded Values to Readable Format and Replace Nulls with Default Values.
SELECT 
	DISTINCT subcat
FROM stage.erp_px_cat_g1v2;

-- Check for Unwanted Spaces.
-- Action: Trim Unwanted Spaces.
SELECT 
	cat, subcat, maintenance
FROM stage.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance) OR cat != TRIM(cat) OR subcat != TRIM(subcat);

SELECT * FROM stage.erp_px_cat_g1v2;
