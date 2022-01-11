use data_bank;

SELECT *
FROM data_bank.customer_nodes;

SELECT *
FROM data_bank.customer_transactions;

SELECT *
FROM data_bank.regions;

-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?
SELECT DISTINCT(node_id) as total
FROM data_bank.customer_nodes
ORDER BY node_id ASC;

-- 2. What is the number of nodes per region?
SELECT customer_nodes.region_id, regions.region_name, COUNT(DISTINCT customer_nodes.node_id) as total
FROM data_bank.customer_nodes customer_nodes
LEFT JOIN data_bank.regions regions ON customer_nodes.region_id = regions.region_id 
GROUP BY customer_nodes.region_id, regions.region_name
ORDER BY node_id ASC;

-- 3. How many customers are allocated to each region?
SELECT customer_nodes.region_id, regions.region_name, COUNT(DISTINCT customer_nodes.customer_id) as total
FROM data_bank.customer_nodes customer_nodes
LEFT JOIN data_bank.regions regions ON customer_nodes.region_id = regions.region_id 
GROUP BY customer_nodes.region_id, regions.region_name
ORDER BY region_id ASC;

-- 4.

-- 5.

-- SELECT














