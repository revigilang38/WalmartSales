-- Business Problem
-- Q.1 Find different payment method and number of transactions, number of qty sold

SELECT 
	payment_method,
	COUNT(invoice_id),
	SUM(quantity) as qty_sold
FROM walmart
GROUP BY 1



-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category

SELECT *
FROM (
	SELECT 
		branch,
		category,
		AVG(rating) as avg_rate,
		RANK()OVER(PARTITION BY branch ORDER BY AVG(rating) DESC ) as rnk
	FROM walmart
	GROUP BY 1,2
)
WHERE rnk =1


-- Q.3 Identify the busiest day for each branch based on the number of transactions


SELECT * 
FROM (
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YYYY'), 'Day') as day_name,
		count(invoice_id),
		RANK()OVER(PARTITION BY branch ORDER BY COUNT(invoice_id)DESC) as rnk
	FROM walmart
	GROUP BY 1,2
)where rnk=1





-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT
	payment_method,
	sum(quantity) as total_qty
FROM walmart
GROUP BY 1


-- Q.5 Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	AVG(rating) as avg_rating,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating
FROM walmart
GROUP BY 1,2

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT
	category,
	sum(total) as total_revenue,
	sum(total * profit_margin) as profit
FROM walmart
GROUP BY 1
ORDER BY profit DESC


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH CTE as (
SELECT 
	branch,
	payment_method,
	COUNT(*) as total_tr,
	ROW_NUMBER()OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rw_nmbr
FROM walmart
GROUP BY 1,2
)

select branch, payment_method
from CTE
where rw_nmbr =1


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT category,
	CASE
		WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift,
	COUNT(*) as total_invoice
FROM walmart
GROUP BY 1,2
ORDER BY 3 DESC


-- #9 Identify 5 branch with highest decrese ratio in 
-- revenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

WITH revenue_2022 
AS (
	SELECT 
		branch,
		SUM(total) as revenue 
	FROM walmart
	WHERE EXTRACT(YEAR from TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),
revenue_2023 AS (
	SELECT 
		branch,
		SUM(total) as revenue 
	FROM walmart
	WHERE EXTRACT(YEAR from TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT 
	ly.branch,
	ly.revenue as ly_revenue, 
	cy.revenue as cy_revenue,
	ROUND((ly.revenue - cy.revenue)::numeric / ly.revenue ::numeric  * 100,2)	 as ratio
FROM revenue_2022 as ly
JOIN 
revenue_2023 as cy
ON ly.branch= cy.branch
WHERE ly.revenue > cy.revenue
ORDER BY ratio desc
LIMIT 5


