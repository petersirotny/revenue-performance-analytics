WITH countries_revenue AS (
SELECT
		c.country,
		SUM(oi.quantity * oi.unit_price) AS country_revenue
FROM
	order_items oi
JOIN orders o ON
	o.order_id = oi.order_id
JOIN customers c ON
	c.customer_id = o.customer_id
WHERE
	o.status = 'completed'
GROUP BY
	c.country),
total_revenue_all AS (
SELECT
		country,
		country_revenue,
		SUM(country_revenue) OVER () AS total_revenue
FROM
	countries_revenue)
SELECT
	country,
	country_revenue,
	ROUND(country_revenue * 1.0 / total_revenue * 100, 2) AS share_of_total
FROM
	total_revenue_all
ORDER BY
	country_revenue DESC;
