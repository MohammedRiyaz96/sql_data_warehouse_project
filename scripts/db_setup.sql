/*
==========================================================================================
DB Setup: Create Database and Schemas.
==========================================================================================
Script Purpose:
	The script creates a new database and schemas ('raw', 'stage' and 'report') within it.
==========================================================================================
*/

/*
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO
*/

USE master;

-- Creating a new database.
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- Creating database schemas.
CREATE SCHEMA raw;
GO

CREATE SCHEMA stage;
GO

CREATE SCHEMA report;
GO
