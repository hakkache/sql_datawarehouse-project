/*********************************************************************************************
 Script Name   : Create_DataWarehouse_Structure.sql
 Author         : [HAKKACHE MOHAMED]
 Date Created   : [10/28/2025]
 Description    : 
    This script automates the setup of the Data Warehouse environment by:
      1. Dropping the existing 'DataWarehouse' database if it exists.
      2. Recreating a fresh 'DataWarehouse' database.
      3. Creating the standard multi-layer schemas:
           - bronze: for raw data ingestion
           - silver: for cleaned and transformed data
           - gold  : for aggregated, curated, and business-ready data

 Usage          :
    - Execute this script in the context of the 'master' database.
    - Ensure no active connections exist to 'DataWarehouse' before running.
*********************************************************************************************/



USE master;

GO

-- Drop and recreate the 'Datawarehouse' database 

IF EXISTS (SELECT 1 FROM sys.databases WHERE name ='DataWarehouse')

BEGIN	
	ALTER DATABASE DataWarehouse  SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;
	DROP DATABASE DataWarehouse ;
END;
GO

-- Create Database 'Datawarehouse'
	
CREATE DATABASE DataWarehouse;

GO

USE DataWarehouse ;

GO

--Create Schemas

CREATE SCHEMA bronze ;
GO
CREATE SCHEMA silver ;
GO
CREATE SCHEMA gold ;
GO
