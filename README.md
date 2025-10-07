# **Data Warehouse and Analytics Project**

This project engineers a comprehensive data warehousing and analytics solution, from building a data warehouse encompassing end-to-end ETL processes to developing actionable insights for business intelligence and reporting.

---
## **Project Overview**

This project comprises 4 phases.
1. **Architecture Build:** Developed a modern Data Warehouse in Medallion Architecture consisting of Raw, Stage and Report layers.
  - **Raw Layer:** Holds raw data from the source systems. Imported data from .CSV files into SQL Server database.
  - **Stage Layer:** Prepares data for analysis. Transformations include data cleansing, standardization, normalization, etc. were handled                      in this phase.
  - **Report Layer:** Keeps data ready for business to analyze. Data modeled in star schema for analytics reporting.


2. **ETL Process:** Involves with Extracting, Transforming and Loading data from source systems into data warehouse.
  - **Extraction:** Full Extraction (method-Pull), File Parsing (.csv).
  - **Transformation:** Data Cleansing (remove duplicates, handling missing data, handling invalid values, data filtering, handling extra                          spaces, data type casting), Data Aggregations, Data Standardization, Data Integration, Derived Columns and Data                            Enrichment.
  - **Loading:** Batch Processing, Full Load (truncate & insert), SCD 1.  


3. **Data Modeling:** Modeled data into Dimension and Fact tables with relationships for query analysis.


4. **Analytics & Reporting:** Performed basic explorations, advanced analytics and reporting.
  - **Basic Explorations:** Includes exploring database tables and its columns, exploring dimensions, dates and measures, magnitude and                                ranking analysis.
  - **Advanced Analytics:** Interpreted with Change-Over-Time, Cumulative, Performance, Part-to-Whole, Data Segmentation analysis.
  - **Reporting:** Built reports with metrics and KPIs for business insights.
