	CREATE DATABASE pizzasales;
    SHOW TABLES;
    SELECT * FROM pizzas;
    SELECT * FROM pizza_types;
    
    CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY(ORDER_ID)
    );
    
    SELECT * FROM orders;
    
    CREATE TABLE order_details(
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY(order_details_id)
    );
    
    SELECT * FROM order_details;
    
    
-- Total orders placed

SELECT count(order_id) AS total_orders FROM orders; 

-- Revenue form pizza sales

SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Revenue 
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id ;

-- Highest priced pizza

SELECT pizza_types.name , pizzas.price 
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1;

-- Most common pizza size 

SELECT pizzas.size , COUNT(order_details.order_details_id) AS size_count
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size ORDER BY size_count DESC LIMIT 1;

-- 5 most ordered pizza types

SELECT pizza_types.name , SUM(order_details.quantity) AS quantity
FROM  pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC LIMIT 5;

-- Total of each pizza category

SELECT pizza_types.category, SUM(order_details.quantity) AS quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category ORDER BY quantity DESC;

-- Distribution of orders by hours of the day

SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC;

-- Category wise distribution of pizza

SELECT pizza_types.category, SUM(order_details.quantity)
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY SUM(order_details.quantity) DESC;

-- Average number of pizzas ordered per day

SELECT ROUND(AVG(total_orders),0) AS avg_orders FROM 
(SELECT orders.order_date ,SUM(order_details.quantity) AS total_orders
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS order_quantity;

-- Top 3 ordered pizza based on revenue 

SELECT pizza_types.name , SUM(pizzas.price * order_details.quantity) AS revenue
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.name 
ORDER BY revenue DESC LIMIT 3;

-- Percentage contribution of each category to revenue

SELECT pizza_types.category, 
ROUND((SUM(pizzas.price * order_details.quantity) / (SELECT SUM(pizzas.price * order_details.quantity) 
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id))*100, 2) AS contribution
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY contribution DESC;

-- Cumulative revenue generated over time

SELECT order_date, ROUND(SUM(revenue) 
OVER (ORDER BY order_date),2) AS cumulative_revenue
FROM
(SELECT orders.order_date, ROUND(SUM(pizzas.price * order_details.quantity),2) 
AS revenue 
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id 
GROUP BY orders.order_date) AS revenue_table;

-- Top 3 pizza types based on revenue for each pizza category

SELECT name, category, revenue
FROM
(SELECT category, name, revenue,
RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS ranking 
FROM
(SELECT pizza_types.category, pizza_types.name, 
ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue 
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category, pizza_types.name) AS revenue) AS main
WHERE ranking <= 3;
