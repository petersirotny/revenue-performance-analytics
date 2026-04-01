WITH revenue_per_customer_per_country AS (
SELECT
	c.country,
	c.customer_id,
	c.customer_name,
	SUM(oi.quantity * oi.unit_price) AS customer_revenue
FROM
	order_items oi
JOIN orders o
        ON
	o.order_id = oi.order_id
JOIN customers c
        ON
	c.customer_id = o.customer_id
WHERE
	o.status = 'completed'
GROUP BY
	c.country,
	c.customer_id,
	c.customer_name
),
ranked AS (
SELECT
	country,
	customer_id,
	customer_name,
	customer_revenue,
	ROW_NUMBER() OVER (
            PARTITION BY country
ORDER BY
	customer_revenue DESC
        ) AS rn
FROM
	revenue_per_customer_per_country
),
top3_customers AS (
SELECT
	country,
	customer_id,
	customer_name,
	customer_revenue
FROM
	ranked
WHERE
	rn <= 3
),
top3_revenue_all AS (
SELECT
	country,
	SUM(customer_revenue) AS top3_customer_revenue
FROM
	top3_customers
GROUP BY
	country
),
country_revenue AS (
SELECT
	c.country,
	SUM(oi.quantity * oi.unit_price) AS country_revenue
FROM
	order_items oi
JOIN orders o
        ON
	o.order_id = oi.order_id
JOIN customers c
        ON
	c.customer_id = o.customer_id
WHERE
	o.status = 'completed'
GROUP BY
	c.country
)
SELECT
	c.country,
	c.country_revenue,
	t.top3_customer_revenue,
	ROUND(t.top3_customer_revenue * 1.0 / c.country_revenue * 100, 2) AS share_top_3
FROM
	country_revenue c
JOIN top3_revenue_all t
    ON
	t.country = c.country
ORDER BY
	share_top_3 DESC;