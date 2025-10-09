
--------------------------------- CHANGE OVER TIME ANALYSIS (TRENDS) -------------------------------------------

-- Yearly & Monthly Sales, Total Customers and Total Quantities Sold by Year and by Month.
SELECT 
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS month_number,
	DATENAME(month, order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT(customer_key)) AS total_customers,
	SUM(quantity) AS total_quantity
FROM report.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date), DATENAME(month, order_date)
ORDER BY order_year, month_number;

------------------------------------------ CUMULATIVE ANALYSIS (TRENDS) -------------------------------------------

-- Analyze Monthly and Yearly Sales Progression of the business.

-- Running Total Sales & Moving Average Price - Monthly:
SELECT
	*,
	SUM(total_sales) OVER(PARTITION BY order_year ORDER BY order_year, order_month) AS running_monthly_total_sales,
	AVG(avg_price) OVER(PARTITION BY order_year ORDER BY order_year, order_month) AS moving_monthly_avg_price
FROM (
	SELECT
		DATETRUNC(year, order_date) AS order_year,
		DATETRUNC(month, order_date) AS order_month,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM report.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(year, order_date), DATETRUNC(month, order_date) 
	) x;


-- Running Total Sales & Moving Average Price - Yearly:
SELECT
	*,
	SUM(total_sales) OVER(ORDER BY order_year) AS running_yearly_total_sales,
	SUM(avg_price) OVER(ORDER BY order_year) AS moving_yearly_avg_price
FROM (
	SELECT
		DATETRUNC(year, order_date) AS order_year,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM report.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(year, order_date)
	) x;

------------------------------------------ PERFORMANCE ANALYSIS -------------------------------------------

/* Analyze the yearly performnace of products by comparing their sales with the average sales performance of the product 
and the previous year sales */
WITH cte AS (
	SELECT
		YEAR(order_date) AS order_year,
		product_name,
		SUM(sales_amount) AS current_sales
	FROM report.fact_sales s
	JOIN report.dim_products p
		ON s.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), product_name
	)
SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_current_vs_avg,
	CASE WHEN current_sales > AVG(current_sales) OVER(PARTITION BY product_name) THEN 'Above Average'
		 WHEN current_sales < AVG(current_sales) OVER(PARTITION BY product_name) THEN 'Below Average'
		 ELSE 'Equals Average'
		 END AS avg_flag,

-- YOY (Year Over Year) Analysis --
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_current_vs_prev,
	CASE WHEN current_sales > LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) THEN 'Increase in Sale'
		 WHEN current_sales < LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) THEN 'Decrease in Sale'
		 ELSE 'No Change'
		 END AS prev_flag
FROM cte;

------------------------------------------ PART TO WHOLE ANALYSIS -------------------------------------------

-- Which product category contribute the most to overall sales?
WITH cte AS (
	SELECT category, SUM(sales_amount) AS total_sales
	FROM report.dim_products p
	JOIN report.fact_sales s
		ON p.product_key = s.product_key
	GROUP BY category
	)
SELECT 
	*, 
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM cte
ORDER BY total_sales DESC;

------------------------------------------ DATA SEGMENTATION -------------------------------------------

-- Segment products into cost ranges and Count how many products fall into each segment.
WITH cte AS (
	SELECT
		product_key,
		cost,
		CASE WHEN cost < 100 THEN 'less_than_100'
			 WHEN cost BETWEEN 100 AND 500 THEN '100_to_500'
			 WHEN cost BETWEEN 500 AND 1000 THEN '500_to_1000'
			 ELSE 'Above 1000'
			 END AS cost_range
	FROM report.dim_products
	)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM cte
GROUP BY cost_range
ORDER BY total_products DESC;


/* Group customers into 3 segments based on their spending behaviour.
	-> VIP: Customers with atleast 12 months of history and spending more than 5,000.
	-> Regular: Customers with atleast 12 months of history but spending 5,000 or less.
	-> New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group. */
WITH cte AS (
	SELECT
		c.customer_key,
		SUM(sales_amount) AS total_spending,
		MAX(order_date) AS last_order,
		MIN(order_date) AS first_order,
		ABS(DATEDIFF(month, MAX(order_date), MIN(order_date))) AS lifespan_months
	FROM report.dim_customers c
	JOIN report.fact_sales s
		ON c.customer_key = s.customer_key
	GROUP BY c.customer_key
	)
SELECT 
	customer_segments, 
	COUNT(customer_key) AS total_customers
FROM (
	SELECT
		customer_key,
		total_spending,
		lifespan_months,
		CASE WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
			 END AS customer_segments
	FROM cte
	) x
GROUP BY customer_segments
ORDER BY total_customers DESC;

------------------------------------------ REPORTING -------------------------------------------
/*
================================================================================================
Customer Report
================================================================================================

Purpose: This report consolidates key customer metrics and behaviours.

Highlights:
	1. Gathers essential fields such as names, ages and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregate customer level metrics:
		- Total orders
		- Total sales
		- Total quantities purchased
		- Total products
		- Lifespan (in months)
	4. Calculate valuable KPIs:
		- Recency (months since last year)
		- Average order value
		- Average monthly spend
================================================================================================
*/

CREATE VIEW report.v_customer_report AS
WITH customer_basic_info AS (
	SELECT
		c.customer_key,
		CONCAT(first_name, ' ', last_name) AS customer_name,
		ABS(DATEDIFF(year, GETDATE(), birth_date)) AS age,
		order_date,
		order_number,
		product_key,
		sales_amount,
		quantity
	FROM report.dim_customers c
	JOIN report.fact_sales s
		ON c.customer_key = s.customer_key
	WHERE order_date IS NOT NULL
	),
customer_metrics AS (
	SELECT
		customer_key,
		customer_name,
		age,
		COUNT(DISTINCT(order_number)) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantities_purchased,
		COUNT(DISTINCT(product_key)) AS total_products,
		MAX(order_date) AS last_order_date,
		ABS(DATEDIFF(month, MAX(order_date), MIN(order_date))) AS lifespan
	FROM customer_basic_info
	GROUP BY customer_key, customer_name, age
	)
SELECT 
	customer_key,
	customer_name,
	age,
	CASE WHEN age < 20 THEN 'Under 20'
		 WHEN age BETWEEN 20 AND 29 THEN '20_to_29'
		 WHEN age BETWEEN 30 AND 39 THEN '30_to_39'
		 WHEN age BETWEEN 40 AND 49 THEN '40_to_49'
		 ELSE '50 and above'
		 END AS age_group,
	total_orders,
	total_sales,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders										-- Average Order Value (AOV)
		 END AS avg_order_value,
	total_quantities_purchased,
	total_products,
	lifespan,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			 ELSE 'New'
			 END AS customer_segments,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan											  -- Average Monthly Spend
		 END AS avg_monthly_spend,												
	last_order_date,
	ABS(DATEDIFF(month, last_order_date, GETDATE())) AS months_since_last_order
FROM customer_metrics;


/*
================================================================================================
Product Report
================================================================================================

Purpose: This report consolidates key product metrics and behaviours.

Highlights:
	1. Gathers essential fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High Performers, Mid Range and Low Performers.
	3. Aggregate product level metrics:
		- Total orders
		- Total sales
		- Total quantities sold
		- Total customers
		- Lifespan (in months)
	4. Calculate valuable KPIs:
		- Recency (months since last sale)
		- Average order revenue
		- Average monthly revenue
================================================================================================
*/

CREATE VIEW report.v_product_report AS
WITH product_metrics AS (
	SELECT
		p.product_key,
		product_name,
		category,
		subcategory,
		cost,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantities_sold,
		COUNT(DISTINCT order_number) AS total_orders,
		MAX(order_date) AS last_order_date,
		ABS(DATEDIFF(month, MAX(order_date), MIN(order_date))) AS product_lifespan,
		COUNT(DISTINCT s.customer_key) AS total_customers,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
	FROM report.dim_products p
	JOIN report.fact_sales s
		ON p.product_key = s.product_key
	WHERE order_date IS NOT NULL
	GROUP BY
		p.product_key,
		product_name,
		category,
		subcategory,
		cost
	)
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_sales,
	total_quantities_sold,
	total_orders,
	total_customers,
	product_lifespan,
	CASE WHEN total_sales > 50000 THEN 'High Performer'
		 WHEN total_sales >= 10000 THEN 'Mid Range'
		 ELSE 'Low Performer'
		 END AS product_segment,
	ABS(DATEDIFF(month, last_order_date, GETDATE())) AS months_since_last_sale,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders									  -- Average Order Revenue (AOR)
		 END AS avg_order_revenue,											
	CASE WHEN product_lifespan = 0 THEN total_sales
		 ELSE total_sales / product_lifespan								-- Average Monthly Revenue (AMR)
		 END AS avg_monthly_revenue											
FROM product_metrics;
