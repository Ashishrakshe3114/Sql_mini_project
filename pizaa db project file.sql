-- Retrieve the total number of orders placed 

SELECT COUNT(DISTINCT order_id) AS total_orders
FROM order_details;

-- Calculate the total revenue generated from pizza sales. 


SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza. 

SELECT 
    pizza_id,
    price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered. 

SELECT 
    p.size,
    SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities. 

SELECT 
    pt.name AS pizza_name,
    SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered. 

SELECT 
    pt.category,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day. 

SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_hour;

-- 3. Join relevant tables to find the category-wise distribution of pizzas. 

SELECT 
    pt.category,
    COUNT(p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_pizzas DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(daily_orders), 2) AS avg_pizzas_per_day
FROM (
    SELECT 
        o.order_date,
        SUM(od.quantity) AS daily_orders
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_stats;

-- 5. Determine the top 3 most ordered pizza types based on revenue. 


SELECT 
    pt.name AS pizza_name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

--  Calculate the percentage contribution of each pizza type to total revenue. 

SELECT 
    pt.name AS pizza_name,
    ROUND(SUM(od.quantity * p.price), 2) AS pizza_revenue,
    ROUND(
        (SUM(od.quantity * p.price) / 
        (SELECT SUM(od2.quantity * p2.price)
         FROM order_details od2
         JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id) * 100), 
    2) AS revenue_percentage
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;

--  Analyze the cumulative revenue generated over time. 

SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
    ROUND(SUM(SUM(od.quantity * p.price)) 
          OVER (ORDER BY o.order_date), 2) AS cumulative_revenue
FROM orders o
JOIN order_details od 
    ON o.order_id = od.order_id
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category

WITH pizza_revenue AS (
    SELECT 
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity * p.price) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY pt.category 
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rank_within_category
    FROM order_details od
    JOIN pizzas p 
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt 
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)
SELECT 
    category,
    pizza_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM pizza_revenue
WHERE rank_within_category <= 3
ORDER BY category, total_revenue DESC;










