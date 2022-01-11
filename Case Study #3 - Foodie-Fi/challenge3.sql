-- A. Customer Journey
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

-- Answer for A
-- From 8 customers, 6 of them are continuing their subscription plan and only 2 customers who decided to stop any subscription.



-- B. Data Analysis Questions
-- Tables:	- foodiefi.customer_sample
-- 			- foodiefi.plans
-- 			- foodiefi.subscriptions

-- Questions & Query --			
--         V         --
-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) as Total_Customer
FROM foodiefi.subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
WITH subscriptions_base AS (
	SELECT a.*, b.plan_name, b.price
    FROM foodiefi.subscriptions a
    LEFT JOIN foodiefi.plans b 
    ON a.plan_id = b.plan_id
)
SELECT start_month, count(1) AS Total
FROM (
	SELECT *, DATE_SUB(start_date, INTERVAL (DAY(start_date) - 1) DAY) AS start_month
	FROM subscriptions_base AS subs_base
	WHERE subs_base.plan_name = 'trial'
)AS subs_trsf
GROUP BY MONTH(subs_trsf.start_month)
ORDER BY start_month ASC;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_name, COUNT(1) as Total_plans
FROM(
	SELECT *
	FROM foodiefi.subscriptions
	WHERE YEAR(start_date) > 2020
)AS subs
LEFT JOIN foodiefi.plans plans
ON subs.plan_id = plans.plan_id
GROUP BY plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT *
FROM (
	SELECT base.plan_name, COUNT(1) AS Total_Users, ROUND(((COUNT(1) / (SELECT COUNT(DISTINCT customer_id) FROM foodiefi.subscriptions subs)) * 100), 1) AS Percentages
	FROM(
		SELECT subs.customer_id, subs.plan_id, subs.start_date, plans.plan_name
		FROM foodiefi.subscriptions subs
		LEFT JOIN foodiefi.plans plans
		ON subs.plan_id = plans.plan_id
	)AS base
	GROUP BY base.plan_name
) AS base_counted
WHERE base_counted.plan_name = 'churn';

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT COUNT(1) AS Total_Users, ROUND(((COUNT(1) / (SELECT COUNT(DISTINCT customer_id) FROM foodiefi.subscriptions subs)) * 100), 1) AS Percentages
FROM (
	SELECT *
	FROM(
		SELECT subs.customer_id, subs.plan_id, subs.start_date, plans.plan_name, LEAD(plans.plan_name, 1) OVER (PARTITION BY subs.customer_id ORDER BY subs.start_date ASC) AS next_stage
		FROM foodiefi.subscriptions subs
		LEFT JOIN foodiefi.plans plans
		ON subs.plan_id = plans.plan_id
	)AS base
	WHERE base.plan_name = 'trial' AND base.next_stage = 'churn'
)AS base_counted
GROUP BY base_counted.plan_name;

-- 6. What is the number and percentage of customer plans after their initial free trial?
SELECT COUNT(1) AS Total_Users, ROUND(((COUNT(1) / (SELECT COUNT(DISTINCT customer_id) FROM foodiefi.subscriptions subs)) * 100), 1) AS Percentages
FROM (
	SELECT *
	FROM(
		SELECT subs.customer_id, subs.plan_id, subs.start_date, plans.plan_name, LEAD(plans.plan_name, 1) OVER (PARTITION BY subs.customer_id ORDER BY subs.start_date ASC) AS next_stage
		FROM foodiefi.subscriptions subs
		LEFT JOIN foodiefi.plans plans
		ON subs.plan_id = plans.plan_id
	)AS base
	WHERE base.plan_name = 'trial' AND base.next_stage != 'churn'
)AS base_counted
GROUP BY base_counted.plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT base_counted.planned
	, COUNT(base_counted.planned) AS Total_Users
    , ROUND(((COUNT(base_counted.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM foodiefi.subscriptions subs)) * 100), 1) AS Percentages
FROM(
	SELECT COALESCE(base.customer_id, NULL) AS customer_id
		, COALESCE(base.plan_name, plans.plan_name) as planned
	FROM(
		SELECT subs.customer_id, subs.plan_id, subs.start_date, plans.plan_name
		FROM foodiefi.subscriptions subs
		LEFT JOIN foodiefi.plans plans
		ON subs.plan_id = plans.plan_id
		WHERE start_date IN ('2020-12-31')
	)AS base
	RIGHT JOIN foodiefi.plans plans
	ON base.plan_id = plans.plan_id
)AS base_counted
GROUP BY base_counted.planned;

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(1) AS Total_Users
FROM (
	SELECT subs.customer_id, subs.plan_id, subs.start_date, plans.plan_name
	FROM foodiefi.subscriptions subs
	LEFT JOIN foodiefi.plans plans
	ON subs.plan_id = plans.plan_id
	WHERE plans.plan_name = 'pro annual'
	AND YEAR(subs.start_date) = 2020
)AS base;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
SELECT AVG(base_counted.period) AS avg_taken_days
FROM (
	SELECT base.*, annual.annual_date, annual.annual_name, DATEDIFF(annual.annual_date, base.start_date) AS period
	FROM(
		SELECT subs.*
			, plans.plan_name
		FROM foodiefi.subscriptions subs
		LEFT JOIN foodiefi.plans plans
		ON subs.plan_id = plans.plan_id
		WHERE customer_id IN (SELECT customer_id 
							FROM foodiefi.subscriptions subs 
							LEFT JOIN foodiefi.plans plans
							ON subs.plan_id = plans.plan_id
							WHERE plan_name = 'pro annual')
	)AS base
	LEFT JOIN (SELECT subs2.customer_id, subs2.start_date AS annual_date, plans2.plan_name AS annual_name
							FROM foodiefi.subscriptions subs2 
							LEFT JOIN foodiefi.plans plans2
							ON subs2.plan_id = plans2.plan_id
							WHERE plan_name = 'pro annual') AS annual
	ON base.customer_id = annual.customer_id
    WHERE base.plan_name = 'trial'
)AS base_counted;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH base_table AS (
	SELECT *
	FROM (
		SELECT base.*, annual.annual_date, annual.annual_name, DATEDIFF(annual.annual_date, base.start_date) AS period
		FROM(
			SELECT subs.*
				, plans.plan_name
			FROM foodiefi.subscriptions subs
			LEFT JOIN foodiefi.plans plans
			ON subs.plan_id = plans.plan_id
			WHERE customer_id IN (SELECT customer_id 
								FROM foodiefi.subscriptions subs 
								LEFT JOIN foodiefi.plans plans
								ON subs.plan_id = plans.plan_id
								WHERE plan_name = 'pro annual')
		)AS base
		LEFT JOIN (SELECT subs2.customer_id, subs2.start_date AS annual_date, plans2.plan_name AS annual_name
								FROM foodiefi.subscriptions subs2 
								LEFT JOIN foodiefi.plans plans2
								ON subs2.plan_id = plans2.plan_id
								WHERE plan_name = 'pro annual') AS annual
		ON base.customer_id = annual.customer_id
		WHERE base.plan_name = 'trial'
	)AS base_counted
)SELECT customer_id, period, NTILE(30) OVER (ORDER BY period ASC) AS bucket_no
FROM base_table;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT *
FROM (
	SELECT a.*, b.plan_name, LEAD(b.plan_name, 1) OVER (PARTITION BY a.customer_id ORDER BY a.start_date ASC) AS next_stage
	FROM foodiefi.subscriptions a
	LEFT JOIN foodiefi.plans b
	ON a.plan_id = b.plan_id
	WHERE YEAR(start_date) = 2020
)AS base
WHERE base.plan_name = 'pro monthly'
AND base.next_stage = 'basic_monthly';









