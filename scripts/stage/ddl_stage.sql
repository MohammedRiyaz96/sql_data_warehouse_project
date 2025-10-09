/*
===============================================================================================================
DDL Script: Create Tables in Stage Layer.
===============================================================================================================
Script Purpose:
	This script create tables in the 'stage' schema post dropping existing tables if they already exist. 
	Execute this script to redefine the DDL structure of 'stage' tables.

Note:
	- In case if any new column is derived as part of Transformation process, the respective field names must be 
	  added in this .ddl script before executing it.
	- If any field data type needs to be corrected, make the changes before running the script.
===============================================================================================================
*/

IF OBJECT_ID ('stage.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE stage.crm_cust_info;
CREATE TABLE stage.crm_cust_info (
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_firstname		NVARCHAR(50),
	cst_lastname		NVARCHAR(50),
	cst_marital_status	NVARCHAR(50),
	cst_gndr			NVARCHAR(50),
	cst_create_date		DATE,
	dwh_create_date		DATETIME2 DEFAULT GETDATE()
	);

IF OBJECT_ID ('stage.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE stage.crm_prd_info;
CREATE TABLE stage.crm_prd_info (
	prd_id			INT,
	cat_id			NVARCHAR(50),
	prd_key			NVARCHAR(50),
	prd_nm			NVARCHAR(50),
	prd_cost		INT,
	prd_line		NVARCHAR(50),
	prd_start_dt	DATE,
	prd_end_dt		DATE,
	dwh_create_date	DATETIME2 DEFAULT GETDATE()
	);

IF OBJECT_ID ('stage.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE stage.crm_sales_details;
CREATE TABLE stage.crm_sales_details (
	sls_ord_num		NVARCHAR(50),
	sls_prd_key		NVARCHAR(50),
	sls_cust_id		INT,
	sls_order_dt	DATE,
	sls_ship_dt		DATE,
	sls_due_dt		DATE,
	sls_sales		INT,
	sls_quantity	INT,
	sls_price		INT,
	dwh_create_date	DATETIME2 DEFAULT GETDATE()
	);


IF OBJECT_ID ('stage.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE stage.erp_cust_az12;
CREATE TABLE stage.erp_cust_az12 (
	cid					NVARCHAR(50),
	bdate				DATE,
	gen					NVARCHAR(50),
	dwh_create_date		DATETIME2 DEFAULT GETDATE()
	);

IF OBJECT_ID ('stage.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE stage.erp_loc_a101;
CREATE TABLE stage.erp_loc_a101 (
	cid					NVARCHAR(50),
	cntry				NVARCHAR(50),
	dwh_create_date		DATETIME2 DEFAULT GETDATE()
	);

IF OBJECT_ID ('stage.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE stage.erp_px_cat_g1v2;
CREATE TABLE stage.erp_px_cat_g1v2 (
	id					NVARCHAR(50),
	cat					NVARCHAR(50),
	subcat				NVARCHAR(50),
	maintenance			NVARCHAR(50),
	dwh_create_date		DATETIME2 DEFAULT GETDATE()
	);



