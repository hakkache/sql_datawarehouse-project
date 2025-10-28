/*********************************************************************************************
 Script Name   : Load_Bronze_Procedure.sql
 Author         : [HAKKACHE Mohamed]
 Date Created   : [10/28/2025]
 Description    : 
    This script creates or alters the stored procedure [bronze.load_bronze], responsible for 
    **loading raw data into the Bronze layer** of the Data Warehouse.

    The procedure performs the following key operations:
      1. Truncates all existing Bronze tables to ensure a clean data load.
      2. Uses BULK INSERT to load CSV files from local directories into the corresponding tables.
      3. Measures and logs the duration of each table load operation.
      4. Implements TRY...CATCH blocks for error handling and execution logging.

    Data Sources:
      - CRM datasets (Customer, Product, and Sales Details)
        Path: C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_crm\
      - ERP datasets (Customer, Location, and Product Category)
        Path: C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_erp\

 Tables Loaded:
      - bronze.crm_cust_info
      - bronze.crm_prd_info
      - bronze.crm_sales_details
      - bronze.erp_cust_az12
      - bronze.erp_loc_a101
      - bronze.erp_px_cat_g1v2

 Usage          :
    - Run this script within the 'DataWarehouse' database.
    - Ensure the CSV source files exist in the specified directories.
    - The 'bronze' schema and corresponding tables must already exist.

 Notes           :
    - Logs are printed to the SQL console for monitoring load progress and durations.
    - Update file paths as necessary when deploying to another environment.
*********************************************************************************************/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE() ;
		PRINT '======================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '======================================================================';

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Date Into : bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Date Into : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Date Into : crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '----------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Date Into : bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Date Into : erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : bronze.bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Date Into : erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\hakka\Downloads\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '===============================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT ' -Total Load Duration: ' +CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'Seconds';
	END TRY
	BEGIN CATCH
		PRINT '===============================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message'+ ERROR_MESSAGE();
		PRINT 'Error Message'+ CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message'+ CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================================================='
	END CATCH
END
