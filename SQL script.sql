-- OBJECTIVE 1: EXPLORE THE MENU ITEMS TABLE
--	1.	View the menu_items table and write a query to find the number of items on the menu.

SELECT count(*)
FROM SYS.menu_items mi 

--	2.	What are the least and most expensive items on the menu?

SELECT *
FROM SYS.menu_items mi 
ORDER BY PRICE 
LIMIT 5

SELECT *
FROM SYS.menu_items mi 
ORDER BY PRICE DESC
LIMIT 5


--	3.	How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?

SELECT COUNT(*)
FROM SYS.menu_items mi 
WHERE CATEGORY='Italian'

--	4.	How many dishes are in each category? What is the average dish price within each category? What's the most and least expensive?

SELECT category, COUNT(*) AS 'numberofdishes', round(AVG(price), 2) as 'Average price', MAX(price), MIN(PRICE)
FROM SYS.menu_items mi 
GROUP BY category 


-- OBJECTIVE 2: EXPLORE THE MENU ITEMS TABLE
--	1.	View the order_details table. What is the date range of the table?
SELECT *
FROM SYS.order_details od 

SELECT MIN(ORDER_DATE), MAX(ORDER_DATE)
FROM SYS.order_details od 

-- 2.	How many orders were made within this date range? How many items were ordered within this date range?

SELECT COUNT(DISTINCT ORDER_ID)
FROM SYS.order_details od 

-- 3.	Which orders had the most number of items?
SELECT COUNT(ITEM_ID), ORDER_ID
FROM SYS.order_details od 
GROUP BY order_id 
ORDER BY COUNT(item_id) DESC
LIMIT 10

-- 4.	How many orders had more than 12 items? 
SELECT COUNT(*)
FROM (
	SELECT  ORDER_ID, COUNT(ITEM_ID)
	FROM SYS.order_details od 
	GROUP BY order_id 
	HAVING COUNT(item_id)>12
) AS SUBQUERY_ALIAS

-- OBJECTIVE 3: ANALYZE CUSTOMER BEHAVIOR
-- 	1.	Combine the menu_items and order_details tables into a single table.

SELECT * FROM SYS.order_details od 
LEFT JOIN SYS.menu_items mi 
	ON OD.item_id = MI.menu_item_id 

--	2.	What were the least and most ordered items? What categories were they in?
	
SELECT COUNT(*) AS NUM_PURCHASES, ITEM_NAME, CATEGORY
FROM  SYS.order_details od LEFT JOIN SYS.menu_items mi 
	ON OD.item_id = MI.menu_item_id 
GROUP BY ITEM_NAME, CATEGORY
ORDER BY count(*) DESC
	
--	3.	What were the top 5 orders that spent the most money?

SELECT ORDER_ID, SUM(PRICE)
FROM  SYS.order_details od LEFT JOIN SYS.menu_items mi 
	ON OD.item_id = MI.menu_item_id 
GROUP BY ORDER_ID
ORDER BY SUM(PRICE) DESC 
LIMIT 5

--	4.	View the details of the highest spend order. Which specific items were purchased?

SELECT ORDER_ID, PRICE, CATEGORY, item_name
FROM  SYS.order_details od LEFT JOIN SYS.menu_items mi 
	ON OD.item_id = MI.menu_item_id 	
WHERE order_id = 440
ORDER BY PRICE DESC 

-- 5. How much was the most expensive order
SELECT ORDER_ID, sum(PRICE)
FROM  SYS.order_details od LEFT JOIN SYS.menu_items mi 
	ON OD.item_id = MI.menu_item_id 	
GROUP BY ORDER_ID
ORDER BY sum(PRICE) DESC 
limit 1

--	5. View the details of the top 5 highest spend orders.


SELECT SUM(PRICE), CATEGORY, COUNT(menu_item_id)
FROM  SYS.order_details od LEFT JOIN SYS.menu_items mi 
	ON OD.item_id = MI.menu_item_id 	
WHERE order_id in (440, 2075, 1957, 330, 2675)
GROUP BY category 
ORDER BY SUM(PRICE) DESC 

