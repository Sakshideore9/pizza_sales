use pizaahut;

 create table order_details(
 order_details_id int not null,
 order_id int not null,
pizza_id text  not null,
quantity int not null,
 primary key(order_details_id));
 
 -- Retrieve the total number of orders placed.
 select count(order_id) as orders from orders;
  
-- Calculate the total revenue generated from pizza sales.
 SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC limit 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5; 



-- Join the necessary tables to find the category of each pizza ordered.
SELECT 
    pizza_types.category, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC
LIMIT 5; 

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
-- Group the orders by date and calculate the average number of pizzas ordered per day.
select category ,count(name ) from pizza_types
group by category;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    ROUND(AVG(quantity), 0) AS average
FROM
    (SELECT 
        orders.order_time, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_time) AS order_quantity;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.name ,
sum(order_details.quantity* pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id 
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category ,
round(sum(order_details.quantity* pizzas.price) /( select  round(sum(order_details.quantity* pizzas.price),2) as total_sales

from order_details
join pizzas
on pizzas.pizza_id =order_details.pizza_id )* 100,2) as revenue 
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id 
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by  pizza_types.category
order by revenue desc limit 3;




-- Analyze the cumulative revenue generated over time.
select order_date ,
sum(revenue)over (order by order_date) as cum_revenue
from(
select orders.order_date,
sum(order_details.quantity * pizzas.price)as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id =order_details.order_id
group by orders.order_date)as sales ; 



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue
FROM (
    SELECT 
        category,
        name,
        revenue,
        RANK() OVER (
            PARTITION BY category 
            ORDER BY revenue DESC
        ) AS rn
    FROM (
        SELECT 
            pizza_types.category,
            pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas
            ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details
            ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;


select
