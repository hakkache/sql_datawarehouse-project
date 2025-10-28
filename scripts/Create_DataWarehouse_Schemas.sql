/*
===============================================================================
 Script:       Create_DataWarehouse_Schemas.sql
 Description:  Initializes the 'DataWarehouse' environment by creating the 
               database and the associated schemas: 'bronze', 'silver', and 'gold'.
               
 Functionality:
   • Checks if the 'DataWarehouse' database already exists.
   • Drops and recreates the database if found.
   • Creates the necessary schemas for the Data Lakehouse architecture.

 Warning:
   ⚠️ Executing this script will DROP the existing 'DataWarehouse' database 
   and all associated data. 
   Ensure that backups are in place before running this script.

 Author:       HAKKACHE MOHAMED
 Created On:   10/28/2025
 Version:      1.0
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
