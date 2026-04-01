WITH revenue_per_category AS (
SELECT
		p.category,
		SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM
	order_items oi
JOIN orders o ON
	o.order_id = oi.order_id
JOIN products p ON
	p.product_id = oi.product_id
WHERE
	o.status = 'completed'
GROUP BY
	p.category),
all_categories_revenue AS (
SELECT
		category,
		category_revenue,
		SUM(category_revenue) OVER () AS total_revenue
FROM
	revenue_per_category)
SELECT
	category,
	category_revenue,
	ROUND(category_revenue * 1.0 / total_revenue * 100, 2) AS share_of_total
FROM
	all_categories_revenue
ORDER BY 
	category_revenue DESC;