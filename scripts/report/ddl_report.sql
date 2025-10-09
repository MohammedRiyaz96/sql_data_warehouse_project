/*
===============================================================================================================
DDL Script: Create Views in Report Layer.
===============================================================================================================
Script Purpose:
	This script create views for the Report layer in the data warehouse.
	The Report layer represents the final Dimension and Fact tables (in Star Schema).
	Each view performs transformations and combines data from the Stage layer to produce a clean, enriched and 
	business ready dataset.
	These views can be queried directly for anaytics and reporting.
===============================================================================================================
*/

---------------------------- CREATE DIMENSION: report.dim_customers -----------------------------------------
IF OBJECT_ID ('report.dim_customers', 'V') IS NOT NULL
	DROP VIEW report.dim_customers;

CREATE VIEW report.dim_customers AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number, 
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE 
			WHEN ci.cst_gndr = 'NA' THEN COALESCE(ca.gen, 'NA')
			ELSE ci.cst_gndr
			END AS gender,
		ca.bdate AS birth_date,
		ci.cst_create_date AS create_date
	FROM stage.crm_cust_info ci
	LEFT JOIN stage.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN stage.erp_loc_a101 la
		ON ci.cst_key = la.cid


---------------------------- CREATE DIMENSION: report.dim_products -----------------------------------------
IF OBJECT_ID ('report.dim_products', 'V') IS NOT NULL
	DROP VIEW report.dim_products;

CREATE VIEW report.dim_products AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY pin.prd_start_dt, pin.prd_key) AS product_key,
		pin.prd_id AS product_id,
		pin.prd_key AS product_number,
		pin.prd_nm AS product_name,
		pin.cat_id AS category_id,
		cin.cat AS category,
		cin.subcat AS subcategory,
		cin.maintenance,
		pin.prd_cost AS cost,
		pin.prd_line AS product_line,
		pin.prd_start_dt AS start_date
	FROM stage.crm_prd_info pin
	LEFT JOIN stage.erp_px_cat_g1v2 cin
		ON pin.cat_id = cin.id
	WHERE prd_end_dt IS NULL


------------------------------------ CREATE FACT: report.fact_sales -----------------------------------------
IF OBJECT_ID ('report.fact_sales', 'V') IS NOT NULL
	DROP VIEW report.fact_sales;

CREATE VIEW report.fact_sales AS
	SELECT
		s.sls_ord_num AS order_number,
		p.product_key,
		c.customer_key,
		s.sls_order_dt AS order_date,
		s.sls_ship_dt AS ship_date,
		s.sls_due_dt AS due_date,
		s.sls_sales AS sales_amount,
		s.sls_quantity AS quantity,
		s.sls_price AS price
	FROM stage.crm_sales_details s
	LEFT JOIN report.dim_customers c
		ON s.sls_cust_id = c.customer_id
	LEFT JOIN report.dim_products p
		ON s.sls_prd_key = p.product_number



