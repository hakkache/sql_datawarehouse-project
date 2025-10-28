/*********************************************************************************************
 Script Name   : Create_Bronze_Tables.sql
 Author         : [HAKKACHE Mohamed]
 Date Created   : [10/28/2025]
 Description    : 
    This script creates the foundational **bronze-layer tables** in the DataWarehouse 
    environment. Each table represents a raw data ingestion layer for CRM and ERP systems. 
    The script performs the following actions:
      1. Drops existing tables if they already exist.
      2. Recreates the bronze tables with defined schemas.

    Tables Created:
      - bronze.crm_cust_info      : Raw customer information from CRM
      - bronze.crm_prd_info       : Raw product information from CRM
      - bronze.crm_sales_details  : Raw sales transaction data from CRM
      - bronze.erp_loc_a101       : Location reference data from ERP
      - bronze.erp_cust_az12      : Customer demographic data from ERP
      - bronze.erp_px_cat_g1v2    : Product category and maintenance data from ERP

 Usage          :
    - Execute this script in the 'DataWarehouse' database context.
    - Ensure the 'bronze' schema already exists before execution.
*********************************************************************************************/

IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info(

	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_last_name NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE

);

IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info(
	
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);

IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details(
	
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101(
	
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
	
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2(

	id  NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
)
