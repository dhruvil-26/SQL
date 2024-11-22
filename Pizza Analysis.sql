create database pizza;

use pizza;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

SELECT *
FROM   pizzas;

SELECT *
FROM   pizza_types;

SELECT *
FROM   orders;

SELECT *
FROM   order_details; 

-- Retrieve the total number of orders placed.

SELECT COUNT(*) AS Total_Orders
FROM   orders; 

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(price * quantity), 2) AS Total_Revenue
FROM   pizzas AS p
       JOIN order_details AS o
         ON p.pizza_id = o.pizza_id; 
         
-- Identify the highest-priced pizza.

SELECT name  AS Highest_Priced_Pizza,
       price AS Price
FROM   pizza_types AS pt
       JOIN pizzas AS p
         ON pt.pizza_type_id = p.pizza_type_id
ORDER  BY price DESC
LIMIT  1; 

-- Other Way

SELECT name  AS Highest_Priced_Pizza,
       price AS Price
FROM   pizza_types AS pt
       JOIN pizzas AS p
         ON pt.pizza_type_id = p.pizza_type_id
WHERE  price = (SELECT MAX(price)
                FROM   pizzas)
LIMIT  1; 

-- Identify the most common pizza size ordered.

SELECT size          AS Size,
       SUM(quantity) AS Quantity_Ordered
FROM   order_details AS od
       JOIN pizzas AS p
         ON p.pizza_id = od.pizza_id
GROUP  BY size
ORDER  BY quantity_ordered DESC
LIMIT  1; 

-- List the top 5 most ordered pizza types along with their quantities.

SELECT name          AS Name,
       SUM(quantity) AS Total_Quantity_Ordered
FROM   pizza_types AS pt
       JOIN pizzas AS p
         ON pt.pizza_type_id = p.pizza_type_id
       JOIN order_details AS od
         ON od.pizza_id = p.pizza_id
GROUP  BY name
ORDER  BY SUM(quantity) DESC
LIMIT  5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT category          AS Category,
       SUM(quantity) AS Total_Quantity_Ordered
FROM   pizza_types AS pt
       JOIN pizzas AS p
         ON pt.pizza_type_id = p.pizza_type_id
       JOIN order_details AS od
         ON od.pizza_id = p.pizza_id
GROUP  BY category
ORDER  BY SUM(quantity) DESC; 

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS Hour_Of_Day,
       COUNT(*)         AS No_of_Orders
FROM   orders
GROUP  BY HOUR(order_time)
ORDER  BY HOUR(order_time); 

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category AS Category,
       COUNT(*) AS No_of_Pizza
FROM   pizza_types
GROUP  BY category; 

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT AVG(total_order_per_day) AS Avg_Quantity_Per_Day
FROM   (SELECT order_date    AS Date,
               SUM(quantity) AS Total_Order_Per_Day
        FROM   orders AS o
               JOIN order_details AS od
                 ON o.order_id = od.order_id
        GROUP  BY order_date) AS order_quantity; 
        
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT name                  AS Name,
       SUM(quantity * price) AS Revenue
FROM   pizza_types AS pt
       JOIN pizzas AS p
         ON pt.pizza_type_id = p.pizza_type_id
       JOIN order_details AS od
         ON od.pizza_id = p.pizza_id
GROUP  BY name
ORDER  BY SUM(quantity * price) DESC
LIMIT  3; 

-- Calculate the percentage contribution of each pizza type to total revenue.

-- WITH cte
--      AS (SELECT Sum(quantity * price) AS Total_Revenue
--          FROM   pizza_types AS pt
--                 JOIN pizzas AS p
--                   ON pt.pizza_type_id = p.pizza_type_id
--                 JOIN order_details AS od
--                   ON od.pizza_id = p.pizza_id)
SELECT category AS Category,
       ROUND(( SUM(quantity * price) / (SELECT
               SUM(quantity * price) AS Total_Revenue
                                        FROM   pizza_types AS pt
                                               JOIN pizzas AS p
                                                 ON pt.pizza_type_id =
                                                    p.pizza_type_id
                                               JOIN order_details AS od
                                                 ON od.pizza_id = p.pizza_id) )
             * 100,
       2)       AS Percent_Of_Revenue
FROM   pizza_types AS pt
       JOIN pizzas AS p
         ON pt.pizza_type_id = p.pizza_type_id
       JOIN order_details AS od
         ON od.pizza_id = p.pizza_id
GROUP  BY category
ORDER  BY percent_of_revenue DESC;

-- Analyze the cumulative revenue generated over time.

SELECT DISTINCT order_date                         AS Date,
                Round(Sum(quantity * price)
                        OVER(
                          ORDER BY order_date), 2) AS Cumulative_Revenue
FROM   orders AS o
       JOIN order_details AS od
         ON o.order_id = od.order_id
       JOIN pizzas AS p
         ON p.pizza_id = od.pizza_id; 
         
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH cte
     AS (SELECT pt.category,
                pt.NAME,
                Sum(od.quantity * p.price)                    AS Revenue,
                RANK()
                  OVER (
                    partition BY pt.category
                    ORDER BY Sum(od.quantity * p.price) DESC) AS Rnk
         FROM   pizza_types AS pt
                JOIN pizzas AS p
                  ON p.pizza_type_id = pt.pizza_type_id
                JOIN order_details AS od
                  ON od.pizza_id = p.pizza_id
         GROUP  BY pt.category,
                   pt.NAME)
SELECT Category,
       Name,
       Revenue
FROM   cte
WHERE  rnk <= 3
ORDER  BY category,
          rnk; 

