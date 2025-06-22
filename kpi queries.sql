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
	  
