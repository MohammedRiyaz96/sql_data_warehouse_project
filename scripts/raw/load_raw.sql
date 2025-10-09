/*
===============================================================================================================
Stored Procedure: Load Raw Layer (Source --> Raw)
===============================================================================================================
Script Purpose:
	This stored procedure loads data into the 'raw' schema from external .CSV files.
	The script executes the following two actions:
	1. Truncate raw tables before loading data.
	2. Uses 'BULK INSERT' command to import data from .CSV file to raw tables.
===============================================================================================================
*/

CREATE OR ALTER PROCEDURE raw.load_raw AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '======================================================================';
		PRINT 'Loading Raw Layer';
		PRINT '======================================================================';

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: raw.crm_cust_info';
		TRUNCATE TABLE raw.crm_cust_info;

		PRINT '>> Inserting Data Into Table: raw.crm_cust_info';
		BULK INSERT raw.crm_cust_info
		FROM 'D:\Riyaz\SQL\Projects\NEW\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';

		--SELECT * FROM raw.crm_cust_info;
		--SELECT COUNT(*) FROM raw.crm_cust_info;

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: raw.crm_prd_info';
		TRUNCATE TABLE raw.crm_prd_info;

		PRINT '>> Inserting Data Into Table: raw.crm_prd_info';
		BULK INSERT raw.crm_prd_info
		FROM 'D:\Riyaz\SQL\Projects\NEW\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';

		--SELECT * FROM raw.crm_prd_info;
		--SELECT COUNT(*) FROM raw.crm_prd_info;

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: raw.crm_sales_details';
		TRUNCATE TABLE raw.crm_sales_details;

		PRINT '>> Inserting Data Into Table: raw.crm_sales_details';
		BULK INSERT raw.crm_sales_details
		FROM 'D:\Riyaz\SQL\Projects\NEW\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';

		--SELECT * FROM raw.crm_sales_details;
		--SELECT COUNT(*) FROM raw.crm_sales_details;

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '----------------------------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: raw.erp_cust_az12';
		TRUNCATE TABLE raw.erp_cust_az12;

		PRINT '>> Inserting Data Into Table: raw.erp_cust_az12';
		BULK INSERT raw.erp_cust_az12
		FROM 'D:\Riyaz\SQL\Projects\NEW\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';

		--SELECT * FROM raw.erp_cust_az12;
		--SELECT COUNT(*) FROM raw.erp_cust_az12;

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: raw.erp_loc_a101';
		TRUNCATE TABLE raw.erp_loc_a101;

		PRINT '>> Inserting Data Into Table: raw.erp_loc_a101';
		BULK INSERT raw.erp_loc_a101
		FROM 'D:\Riyaz\SQL\Projects\NEW\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		PRINT '---------------------------';

		--SELECT * FROM raw.erp_loc_a101;
		--SELECT COUNT(*) FROM raw.erp_loc_a101;

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: raw.erp_px_cat_g1v2';
		TRUNCATE TABLE raw.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into Table: raw.erp_px_cat_g1v2';
		BULK INSERT raw.erp_px_cat_g1v2
		FROM 'D:\Riyaz\SQL\Projects\NEW\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' second(s)';
		
		--SELECT * FROM raw.erp_px_cat_g1v2;
		--SELECT COUNT(*) FROM raw.erp_px_cat_g1v2;

		SET @batch_end_time = GETDATE();

		PRINT '=========================================================================';
		PRINT 'Raw Layer has been Loaded Succesfully';
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) 
		+ ' second(s)';
		PRINT '=========================================================================';
	END TRY
	BEGIN CATCH
		PRINT '=========================================================================';
		PRINT 'ERROR OCCURRED DURING LOADING RAW LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================================================';
	END CATCH
END



