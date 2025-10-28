/*********************************************************************************************
 Script Name   : Create_Silver_Tables.sql
 Author        : [HAKKACHE Mohamed]
 Date Created  : [10/28/2025]
 Description   : 
    This script creates the **Silver-layer tables** in the DataWarehouse environment.
    The Silver layer serves as a cleaned and standardized data zone, transforming raw
    data from the Bronze layer into structured, business-ready formats.

    The script performs the following actions:
      1. Drops existing tables if they already exist in the 'silver' schema.
      2. Recreates the Silver tables with the defined schemas.
      3. Adds 'dwh_create_date' columns to track data ingestion timestamps.

    Tables Created:
      - silver.crm_cust_info      : Standardized customer information from CRM
      - silver.crm_prd_info       : Standardized product information from CRM
      - silver.crm_sales_details  : Cleansed sales transaction data from CRM
      - silver.erp_loc_a101       : Processed location reference data from ERP
      - silver.erp_cust_az12      : Standardized customer demographic data from ERP
      - silver.erp_px_cat_g1v2    : Processed product category and maintenance data from ERP

 Usage          :
    - Execute this script in the 'DataWarehouse' database context.
    - Ensure the 'silver' schema already exists before execution.
    - Review and adjust NVARCHAR lengths if necessary to match source data.
*********************************************************************************************/

IF OBJECT_ID ('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info(

	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_last_name NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_marital_status NVARCHAR,
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info(
	
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details(
	
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101(
	
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
	
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2(

	id  NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
