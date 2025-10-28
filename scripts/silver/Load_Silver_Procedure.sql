/*********************************************************************************************
 Script Name   : Load_Silver_Procedure.sql
 Author        : [HAKKACHE Mohamed]
 Date Created  : [10/28/2025]
 Description   : 
    This script creates or updates the stored procedure [silver.load_silver], responsible 
    for transforming and loading data from the Bronze Layer into the Silver Layer within 
    the DataWarehouse environment.

    The procedure performs the following actions:
      1. Truncates existing Silver tables to ensure a clean reload.
      2. Extracts, transforms, and loads (ETL) data from Bronze tables.
      3. Applies standardization, data quality checks, and business rules.
      4. Prints step-by-step logs with timing metrics for transparency and monitoring.
      5. Handles errors gracefully using TRY...CATCH for debugging and traceability.

    Data Domains Processed:
      - CRM: Customer, Product, and Sales Details
      - ERP: Customer, Location, and Product Category Data

    Key Transformations:
      - Cleanses and formats marital status and gender attributes.
      - Normalizes date fields and validates data integrity.
      - Maps product categories and adjusts inconsistent codes.
      - Handles invalid or missing values by assigning 'n/a' placeholders.
      - Converts country codes to readable country names.

 Usage          :
    - Execute this script in the 'DataWarehouse' database context.
    - Ensure that Bronze and Silver tables already exist before running this procedure.
    - The procedure can be executed using:  EXEC silver.load_silver
*********************************************************************************************/

EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GETDATE() ;
		PRINT '======================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '======================================================================';

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into Table : silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_last_name,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname ,
			TRIM(cst_last_name) AS cst_lastname,
			CASE 
				 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'n/a'
			END cst_marital_status,
			CASE 
				 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM
		(
		SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER by cst_create_date DESC) as flag_last
		FROM 
			bronze.crm_cust_info
		WHERE cst_id IS NOT NULL) t 	
		WHERE flag_last =1;
		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into Table : silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(	
			prd_id ,
			cat_id ,
			prd_key,
			prd_nm ,
			prd_cost ,
			prd_line ,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_')  AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key ,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'n/a'
			END prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_end_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE ) AS prd_end_dt
		FROM 
			bronze.crm_prd_info

		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into Table : silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
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
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt)!=8 THEN NULL
					  ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt)!=8 THEN NULL
					  ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt)!=8 THEN NULL
					  ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END sls_due_dt,
			sls_quantity,
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales,
			CASE WHEN sls_price is NULL OR sls_price <= 0 THEN sls_sales/NULLIF(sls_quantity,0)
				 ELSE sls_sales
			END AS sls_price
		FROM bronze.crm_sales_details

		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		PRINT '----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '----------------------------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table : silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into Table : silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen)   
		SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				 ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			 ELSE 'n/a'
		END AS gen
		FROM bronze.erp_cust_az12 

		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into Table : silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (

			cid,
			cntry)

		SELECT 

			REPLACE(cid,'-','') as cid,
			CASE WHEN TRIM(cntry) ='DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry
		FROM
			bronze.erp_loc_a101 
		
		SET @end_time = GETDATE();
		PRINT '>> Load duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds' ;
		PRINT '---------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table : silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into Table : silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
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
		FROM
			bronze.erp_px_cat_g1v2

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
