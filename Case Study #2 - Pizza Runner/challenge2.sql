DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS pizza_runner.customer_orders;
CREATE TABLE pizza_runner.customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


  -- Tasks

  -- Data Cleansing
SET SQL_SAFE_UPDATES = 0;

UPDATE pizza_runner.customer_orders
SET exclusions = NULL
WHERE exclusions IN ('', 'null');

UPDATE pizza_runner.customer_orders
SET extras = NULL
WHERE extras IN ('', 'null');

SELECT *
FROM pizza_runner.customer_orders;

UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE pickup_time IN ('', 'null');

UPDATE pizza_runner.runner_orders
SET distance = NULL
WHERE distance IN ('', 'null');

UPDATE pizza_runner.runner_orders
SET duration = NULL
WHERE duration IN ('', 'null');

UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE cancellation IN ('', 'null');

SELECT *
FROM pizza_runner.runner_orders;

-- -------------------------------------

-- -------------------- Questions ---------------------------
-- Pizza Metrics
-- 1. How many pizzas were ordered?
SELECT COUNT(1)
FROM pizza_runner.customer_orders;


-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) as unique_customer
FROM pizza_runner.customer_orders;


-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(runner_id) as Success
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;


-- 4. How many of each type of pizza was delivered?
SELECT a.pizza_id, COUNT(a.pizza_id) as pizzas_sold
FROM pizza_runner.customer_orders a
LEFT JOIN pizza_runner.runner_orders b
ON a.order_id = b.order_id
WHERE b.cancellation IS NULL
GROUP BY pizza_id;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT a.customer_id, b.pizza_name, COUNT(b.pizza_name) as oredered
FROM pizza_runner.customer_orders a
LEFT JOIN pizza_runner.pizza_names b
ON a.pizza_id = b.pizza_id
GROUP BY a.customer_id, b.pizza_name
ORDER BY a.customer_id ASC, a.order_time ASC;

-- OR

SELECT a.customer_id, SUM(a.meatlovers_flag) as Meatlovers, SUM(a.vegetarian_flag) as Vegetarian
FROM(
	SELECT a.customer_id, a.pizza_id, b.pizza_name,
	CASE
		WHEN pizza_name = 'Meatlovers' THEN 1 ELSE 0
	END AS meatlovers_flag,
	CASE
		WHEN pizza_name = 'Vegetarian' THEN 1 ELSE 0
	END AS vegetarian_flag
	FROM pizza_runner.customer_orders a
	LEFT JOIN pizza_runner.pizza_names b
	ON a.pizza_id = b.pizza_id
)as a
GROUP BY a.customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT order_time, order_id, count(order_id) as total
FROM pizza_runner.customer_orders
GROUP BY order_time
ORDER BY total DESC
LIMIT 1;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT a.customer_id, SUM(CASE WHEN a.exclusions IS NOT NULL OR a.extras IS NOT NULL THEN 1 ELSE 0 END) AS total_change
	, SUM(CASE WHEN a.exclusions IS NULL OR a.extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM(
	SELECT a.customer_id, a.exclusions, a.extras
	FROM pizza_runner.customer_orders a
	LEFT JOIN pizza_runner.runner_orders b
	ON a.order_id = b.order_id
	WHERE b.cancellation IS NULL
) as a
GROUP BY customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(1) as total
FROM pizza_runner.customer_orders a
LEFT JOIN pizza_runner.runner_orders b
ON a.order_id = b.order_id
WHERE b.cancellation IS NULL 
AND a.exclusions IS NOT NULL
AND a.extras IS NOT NULL;


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT hour(order_time) as hour_in_day, count(order_id) as total
FROM pizza_runner.customer_orders
GROUP BY hour(order_time)
ORDER BY hour(order_time) ASC;


-- 10. What was the volume of orders for each day of the week?
SELECT dayofweek(order_time) as week, count(order_id) as total
FROM pizza_runner.customer_orders
GROUP BY dayofweek(order_time);