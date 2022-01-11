--1.
SELECT s.customer_id, SUM(m.price) as total_amount
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id ASC;


--2.
SELECT customer_id, count(customer_id) as total_days
FROM(
  SELECT customer_id, order_date
  FROM dannys_diner.sales
  GROUP BY customer_id, order_date
)as A
GROUP BY customer_id
ORDER BY customer_id ASC;


--3.
SELECT *
FROM(
	SELECT a.*, b.product_name, row_number() over (partition by a.customer_id order by a.order_date asc, 
                                              a.product_id asc) as rnk
	FROM dannys_diner.sales a
	LEFT JOIN dannys_diner.menu b
	ON a.product_id = b.product_id
)as a
WHERE a.rnk = 1;


--4.
SELECT a.product_name, count(a.product_name) as total_purchased
FROM(
  SELECT a.*, b.product_name
  FROM dannys_diner.sales a 
  LEFT JOIN dannys_diner.menu b
  ON a.product_id = b.product_id
)AS a
GROUP BY a.product_name
ORDER BY count(a.product_name) DESC
LIMIT 1;



--5.
SELECT b.customer_id, b.product_name
FROM(
  SELECT *,  RANK() OVER (PARTITION BY a.customer_id ORDER BY a.total_purchased DESC) as rnk
  FROM(
    SELECT a.customer_id, b.product_name, count(b.product_name) as total_purchased
    FROM dannys_diner.sales a 
    LEFT JOIN dannys_diner.menu b
    ON a.product_id = b.product_id
    GROUP BY a.customer_id, b.product_name
    ORDER BY count(b.product_name) DESC
  )AS a
)AS b
WHERE rnk = 1;


--6.
SELECT a.customer_id, a.order_date, c.product_name, a.join_date
FROM(
  SELECT a.customer_id, a.order_date, a.product_id, b.join_date,
  ROW_NUMBER() OVER (PARTITION BY a.customer_id ORDER BY order_date ASC) as rnk
  FROM dannys_diner.sales a
  LEFT JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  WHERE a.customer_id = b.customer_id
  AND a.order_date > / >= b.join_date
)as a
LEFT JOIN dannys_diner.menu c
ON a.product_id = c.product_id
WHERE a.rnk = 1;


--7.
SELECT a.rnk, a.customer_id, a.order_date, c.product_name, a.join_date
FROM(
  SELECT a.customer_id, a.order_date, a.product_id, b.join_date,
  RANK() OVER (PARTITION BY a.customer_id ORDER BY order_date DESC) as rnk
  FROM dannys_diner.sales a
  LEFT JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  WHERE a.customer_id = b.customer_id
  AND a.order_date < b.join_date
)as a
LEFT JOIN dannys_diner.menu c
ON a.product_id = c.product_id
WHERE a.rnk = 1
ORDER BY a.customer_id ASC;



--8.
SELECT a.customer_id, a.product_name, count(a.product_name) as total_items, sum(a.price) as amount
FROM (
  SELECT a.customer_id, a.product_id, c.product_name, c.price, a.order_date, b.join_date
  FROM dannys_diner.sales a
  LEFT JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  LEFT JOIN dannys_diner.menu c
  ON a.product_id = c.product_id
  WHERE a.customer_id = b.customer_id
  AND a.order_date < b.join_date
) AS a
GROUP BY a.customer_id, a.product_name
ORDER BY a.customer_id ASC;


--9.
SELECT a.customer_id, sum(a.points) as total_points
FROM(
	SELECT a.customer_id, CASE WHEN b.product_name = 'sushi' then 2*(b.price*10) else (b.price*10) end as points
	FROM dannys_diner.sales a
	LEFT JOIN dannys_diner.menu b
	ON a.product_id = b.product_id
)AS a
GROUP BY a.customer_id
ORDER BY a.customer_id ASC;


--10.
SELECT a.customer_id, (b.price*10) points, a.order_date, c.join_date, date_part('week',a.order_date) order_week, date_part('week',c.join_date) join_week
FROM dannys_diner.sales a
LEFT JOIN dannys_diner.menu b
ON a.product_id = b.product_id
LEFT JOIN dannys_diner.members c
ON a.customer_id = c.customer_id
ORDER BY a.customer_id ASC, a.order_date ASC;















