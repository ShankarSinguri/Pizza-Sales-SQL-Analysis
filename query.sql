/* KPi's*/:

--Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders


--total revenue generated from pizza sales.

select 
     round(sum(orders_detail.quantity*pizzas.price)::NUMERIC,2 )as revenue
from 
     orders_detail 
join 
     pizzas 
on  
     orders_detail.pizza_id = pizzas.pizza_id


--Identify the highest-priced pizza.

select 
      pizza_type.pizza_name, pizzas.price
from 
      pizza_type
join 
      pizzas 
on   
      pizza_type.pizza_type_id = pizzas.pizza_type_id
order by
      pizzas.price desc
limit 1


-- without limit:

select 
      pizza_type.pizza_name, pizzas.price
from 
      pizza_type
join 
      pizzas 
on   
      pizza_type.pizza_type_id = pizzas.pizza_type_id

where 
      pizzas.price= (select max(pizzas.price) from pizzas)



--Identify the most common pizza size ordered.

select
      pizzas.size,count(orders_detail.order_id) as order_count
from 
      pizzas join orders_detail
on 
      pizzas.pizza_id=orders_detail.pizza_id
group by 
      pizzas.size order by order_count desc


--List the top 5 most ordered pizza types along with their quantities.

select
     pizza_type.pizza_name,
sum
     (orders_detail.quantity) as quantity
from 
     pizza_type 
join 
     pizzas
on 
     pizza_type.pizza_type_id = pizzas.pizza_type_id
join 
     orders_detail
on 
     orders_detail.pizza_id = pizzas.pizza_id
group by 
     pizza_type.pizza_name
order by 
      quantity desc limit 5;

-- without limit:	  

SELECT 
    pizza_name,
    quantity
FROM (
    SELECT 
        pizza_type.pizza_name,
        SUM(orders_detail.quantity) AS quantity,
        RANK() OVER (ORDER BY SUM(orders_detail.quantity) DESC) AS rnk
    FROM 
        pizza_type
    JOIN 
        pizzas ON pizza_type.pizza_type_id = pizzas.pizza_type_id
    JOIN 
        orders_detail ON orders_detail.pizza_id = pizzas.pizza_id
    GROUP BY 
        pizza_type.pizza_name
) AS ranked_pizzas
WHERE 
    rnk <= 5;


-- find the total quantity of each pizza category ordered.

SELECT 
    pizza_type.category,
    SUM(orders_detail.quantity) AS total_quantity
FROM 
    orders_detail
JOIN 
    pizzas ON orders_detail.pizza_id = pizzas.pizza_id
JOIN 
    pizza_type ON pizzas.pizza_type_id = pizza_type.pizza_type_id
GROUP BY 
    pizza_type.category
ORDER BY 
    total_quantity DESC;


--Determine the distribution of orders by hour of the day.

SELECT 
    EXTRACT(HOUR FROM time) AS hour, 
    COUNT(order_id) AS order_count
FROM 
    orders
GROUP BY 
    EXTRACT(HOUR FROM time)
ORDER BY 
    hour;

--find the category-wise distribution of pizzas.

select category, count(pizza_name) from pizza_type
group by category


--Group the orders by date and calculate the average number of pizzas ordered per day.

select 
    round(avg(quantity),0) as average_pizzas_orderd_per_dat 
from
    (select orders.date,sum(orders_detail.quantity) as quantity
from orders join orders_detail 
     on orders.order_id = orders_detail.order_id
group by orders.date) as order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.

select 
     pizza_type.pizza_name,
sum
   (orders_detail.quantity*pizzas.price) as revenue
from 
    pizza_type 
join 
    pizzas on pizzas.pizza_type_id = pizza_type.pizza_type_id
join 
    orders_detail on orders_detail.pizza_id = pizzas.pizza_id
group by 
     pizza_type.pizza_name
order by
     revenue desc
limit 3;

--Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_type.category,
    ROUND(
      SUM(orders_detail.quantity * pizzas.price)::NUMERIC 
      / (
          SELECT SUM(orders_detail.quantity * pizzas.price)::NUMERIC
          FROM orders_detail
          JOIN pizzas ON pizzas.pizza_id = orders_detail.pizza_id
        ) * 100,
      2
    ) AS revenue_percentage
FROM pizza_type
JOIN pizzas 
  ON pizza_type.pizza_type_id = pizzas.pizza_type_id
JOIN orders_detail 
  ON orders_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.category
ORDER BY revenue_percentage DESC;


--Analyze the cumulative revenue generated over time.

SELECT 
    date,
    SUM(sales.revenue) OVER (ORDER BY sales.date) AS cum_revenue
FROM (
    SELECT 
        orders.date,
        SUM(orders_detail.quantity * pizzas.price) AS revenue
    FROM 
        orders_detail 
    JOIN 
        pizzas ON orders_detail.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON orders.order_id = orders_detail.order_id
    GROUP BY 
        orders.date
) AS sales


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT 
    pizza_name, revenue 
FROM (
    SELECT 
        category,
        pizza_name,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_type.category, 
            pizza_type.pizza_name,
            SUM(orders_detail.quantity * pizzas.price) AS revenue
        FROM 
            pizza_type 
        JOIN 
            pizzas ON pizza_type.pizza_type_id = pizzas.pizza_type_id
        JOIN 
            orders_detail ON orders_detail.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_type.category, 
            pizza_type.pizza_name
    ) AS a
) AS b
WHERE 
    rn <= 3;


	
	  
