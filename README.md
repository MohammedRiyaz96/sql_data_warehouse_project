# **Data Warehouse and Analytics Project**
This project engineers a comprehensive data warehousing and analytics solution, from building a data warehouse encompassing end-to-end ETL processes to developing actionable insights for business intelligence and reporting.

# **Data Architecture**
This project is built with Medallion Architecture consisting of **Raw**, **Stage** and **Report** layers.
1. **Raw Layer:** Holds raw data from the source systems. Imported data from .CSV files into SQL Server database.
2. **Stage Layer:** Prepares data for analysis. Transformations include data cleansing, standardization, normalization, etc. were handled in this phase.
3. **Report Layer:** Keeps data ready for business to analyze. Data modeled in star schema for analytics reporting.

# **Project Overview**
1. **Architecture Build:** Developed a modern Data Warehouse in Medallion Architecture with Raw, Stage and Report layers. 
2. **ETL Process:** Extracted (file parsing), Transformed (data cleansing, standardization, normalization, etc.) and Loaded (full load) data from source systems into data warehouse.
3. **Data Modeling:** Modeled data into Dimension and Fact tables with relationships for query analysis.
4. **Analytics & Reporting:** Performed basic explorations, advanced analytics and built reports with metrics and KPIs for business insights.
