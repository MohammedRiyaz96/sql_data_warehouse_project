/*
===============================================================================================================
Stored Procedure: Load Stage Layer (Raw --> Stage)
===============================================================================================================
Script Purpose:
	This stored procedure performs ETL (Extract, Transform, Load) process to populate 'stage' schema tables from 
	'raw' schema.
	Actions Performed:
	1. Truncate stage tables before loading data.
	2. Inserts transformed and cleansed data from Raw into Stage tables.
===============================================================================================================
*/

CREATE OR ALTER PROCEDURE stage.load_stage AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '======================================================================';
		PRINT 'Loading Stage Layer';
		PRINT '======================================================================';

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------------------------------------';
		
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: stage.crm_cust_info';
		TRUNCATE TABLE stage.crm_cust_info;

		PRINT '>> Inserting Data Into Table: stage.crm_cust_info';
		INSERT INTO stage.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
			)

		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,											
			TRIM(cst_lastname) AS cst_lastname,											                        -- Handling Extra Space
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'				          -- Data Standardization
				 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'   
				 ELSE 'NA'																                                    -- Handling Missing Value
				 END AS cst_marital_status,
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 ELSE 'NA'
				 END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM raw.crm_cust_info
			WHERE cst_id IS NOT NULL													-- Removing Nulls 
			) x
		WHERE flag_last = 1;															  -- Removing Duplicates 

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';
		

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: stage.crm_prd_info';
		TRUNCATE TABLE stage.crm_prd_info;

		PRINT '>> Inserting Data Into Table: stage.crm_prd_info';
		INSERT INTO stage.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)

		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,							
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,								-- Derived New Column
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,											        -- Handling Missing Value
			CASE UPPER(TRIM(prd_line))													          -- Handling Extra Space
				 WHEN 'M' THEN 'Mountain'												            -- Data Standardization
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'NA'																                  -- Handling Missing Value
				 END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,									  -- Type Casting
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt					
																					                        	-- Data Enrichment
		FROM raw.crm_prd_info;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';


		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: stage.crm_sales_details';
		TRUNCATE TABLE stage.crm_sales_details;

		PRINT '>> Inserting Data Into Table: stage.crm_sales_details';
		INSERT INTO stage.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)

		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

			CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL					-- Handling Invalid Data
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)							        -- Type Casting
				 END AS sls_order_dt,

			CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				 END AS sls_ship_dt,

			CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				 END AS sls_due_dt,

			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				 THEN sls_quantity * ABS(sls_price)				
				 ELSE sls_sales		                            -- Handling Invalid & Missing Data by Deriving New Column from Existing Column							
				 END AS sls_sales,

			sls_quantity,

			CASE WHEN sls_price IS NULL OR sls_price <= 0
				 THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price
				 END AS sls_price

		FROM raw.crm_sales_details;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		
		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '----------------------------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: stage.erp_cust_az12';
		TRUNCATE TABLE stage.erp_cust_az12;

		PRINT '>> Inserting Data Into Table: stage.erp_cust_az12';
		INSERT INTO stage.erp_cust_az12 (
			cid,
			bdate,
			gen
		)

		SELECT
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))					-- Handling Invalid Value
				ELSE cid
				END AS cid,
			CASE 
				WHEN bdate > GETDATE() THEN NULL										          -- Handling Invalid Value
				ELSE bdate
				END AS bdate,
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'				-- Data Standardization
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'NA'																                      -- Handling Missing Value
				END AS gen
		FROM raw.erp_cust_az12;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';
		

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: stage.erp_loc_a101';
		TRUNCATE TABLE stage.erp_loc_a101;

		PRINT '>> Inserting Data Into Table: stage.erp_loc_a101';
		INSERT INTO stage.erp_loc_a101 (
			cid,
			cntry
		)

		SELECT 
			REPLACE(cid, '-', '') AS cid,
			CASE 
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
				WHEN TRIM(cntry) IS NULL OR cntry = '' THEN 'NA'
				ELSE TRIM(cntry)
				END AS cntry
		FROM raw.erp_loc_a101;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';
		

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: stage.erp_px_cat_g1v2';
		TRUNCATE TABLE stage.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into Table: stage.erp_px_cat_g1v2';
		INSERT INTO stage.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
			)

		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM raw.erp_px_cat_g1v2;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';

		SET @batch_end_time = GETDATE();

		PRINT '=========================================================================';
		PRINT 'Stage Layer has been Loaded Succesfully';
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) 
		+ ' second(s)';
		PRINT '=========================================================================';
	END TRY
	BEGIN CATCH
		PRINT '=========================================================================';
		PRINT 'ERROR OCCURRED DURING LOADING STAGE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================================================';
	END CATCH
END

