WITH product_revenue_per_country AS (
SELECT
		c.country,
		p.product_id,
		p.product_name,
		SUM(oi.quantity * oi.unit_price) AS product_revenue
FROM
	order_items oi
JOIN orders o ON
	o.order_id = oi.order_id
JOIN customers c ON
	c.customer_id = o.customer_id
JOIN products p ON
	p.product_id = oi.product_id
WHERE
	o.status = 'completed'
GROUP BY
	c.country,
	p.product_id,
	p.product_name),
ranked AS (
SELECT
		country,
		product_id,
		product_name,
		product_revenue,
		ROW_NUMBER() OVER (PARTITION BY country
ORDER BY
	product_revenue DESC) AS rn
FROM
		product_revenue_per_country),
top_products AS (
SELECT
		country,
		product_id,
		product_name,
		product_revenue
FROM
	ranked
WHERE
	rn = 1),
countries_revenue AS (
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
	c.country)
SELECT
	c.country,
	t.product_name,
	t.product_revenue,
	ROUND(t.product_revenue * 1.0 / c.country_revenue * 100, 2) AS share_of_country
FROM
	countries_revenue c
JOIN top_products t ON
	t.country = c.country
ORDER BY
	c.country;