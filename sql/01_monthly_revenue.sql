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
	strftime('%Y-%m', o.order_date)
ORDER BY
	month;