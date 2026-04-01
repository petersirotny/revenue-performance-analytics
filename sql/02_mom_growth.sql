WITH revenue_per_month AS (
SELECT
		strftime('%Y-%m', o.order_date) AS month,
		SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM
	order_items oi
JOIN orders o ON
	o.order_id = oi.order_id
WHERE
	o.status = 'completed'
GROUP BY
	strftime('%Y-%m', o.order_date)),
previous_months AS (
SELECT
		month,
		monthly_revenue,
		LAG(monthly_revenue) OVER (
ORDER BY
	month) AS previous_revenue
FROM
	revenue_per_month)
SELECT
	month,
	monthly_revenue,
	previous_revenue,
	ROUND((monthly_revenue - previous_revenue) * 1.0 / previous_revenue * 100, 2) AS mom_growth
FROM
	previous_months;