# Pizza-Sales-SQL-Analysis:

# 🍕 Pizza Sales Analysis (SQL)

This repository contains SQL queries that analyze pizza sales data to uncover key performance metrics and trends. The analysis aims to support data-driven decisions around sales, customer behavior, and product optimization.

---

## 🎯 Key Performance Indicators (KPIs)

### 🍕 Total Revenue
```sql
SELECT 
  ROUND(SUM(orders_detail.quantity * pizzas.price)::NUMERIC, 2) AS revenue
FROM orders_detail
JOIN pizzas 
  ON orders_detail.pizza_id = pizzas.pizza_id;
```

### 🍕 Average Pizzas Ordered Per Day
```sql
SELECT ROUND(AVG(quantity), 0) AS average_pizzas_ordered_per_day
FROM (
  SELECT orders.date, SUM(orders_detail.quantity) AS quantity
  FROM orders
  JOIN orders_detail 
    ON orders.order_id = orders_detail.order_id
  GROUP BY orders.date
) AS order_quantity;
```

### 🍕 Total Pizzas Ordered
```sql
SELECT COUNT(order_id) AS total_orders 
FROM orders;
```

### 🍕 Top 3 Most Ordered Pizzas
```sql
WITH ranked_pizzas AS (
  SELECT pizza_type.pizza_name,
         SUM(orders_detail.quantity) AS quantity,
         RANK() OVER (ORDER BY SUM(orders_detail.quantity) DESC) AS rnk
  FROM pizza_type
  JOIN pizzas 
    ON pizza_type.pizza_type_id = pizzas.pizza_type_id
  JOIN orders_detail 
    ON orders_detail.pizza_id = pizzas.pizza_id
  GROUP BY pizza_type.pizza_name
)
SELECT pizza_name, quantity
FROM ranked_pizzas
WHERE rnk <= 3;
```

---

## 🍕 Trend Analysis

### 🍕 Orders Distribution by Hour
```sql
SELECT EXTRACT(HOUR FROM time) AS hour,
       COUNT(order_id) AS order_count
FROM orders
GROUP BY EXTRACT(HOUR FROM time)
ORDER BY hour;
```

### 📅 Monthly Sales Performance
```sql
WITH monthly_sales_data AS (
  SELECT DATE_TRUNC('month', orders.date) AS month,
         ROUND(SUM(orders_detail.quantity * pizzas.price)::NUMERIC, 2) AS monthly_sales
  FROM orders
  JOIN orders_detail 
    ON orders.order_id = orders_detail.order_id
  JOIN pizzas 
    ON orders_detail.pizza_id = pizzas.pizza_id
  GROUP BY DATE_TRUNC('month', orders.date)
)
SELECT month, monthly_sales,
       LAG(monthly_sales) OVER (ORDER BY month) AS prev_month_sales,
       ROUND((monthly_sales - LAG(monthly_sales) OVER (ORDER BY month)), 2) AS month_on_month_change
FROM monthly_sales_data
ORDER BY month;
```

---

## 🍕 Category-wise Analysis

###🍕 Revenue by Category (% of Total Revenue)
```sql
SELECT pizza_type.category,
       ROUND(
         SUM(orders_detail.quantity * pizzas.price)::NUMERIC / 
         (SELECT SUM(orders_detail.quantity * pizzas.price)::NUMERIC
          FROM orders_detail
          JOIN pizzas 
            ON orders_detail.pizza_id = pizzas.pizza_id) * 100, 2
       ) AS revenue_percentage
FROM pizza_type
JOIN pizzas 
  ON pizza_type.pizza_type_id = pizzas.pizza_type_id
JOIN orders_detail 
  ON orders_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.category
ORDER BY revenue_percentage DESC;
```

---

🎯 Findings & Observations:
* Customer preferences skew toward specific pizzas and sizes.
* Peak ordering hours can help optimize operations and reduce wait times.
* Certain pizza types generate a significant proportion of total revenue — these are key to promote further.
* Month-over-month analysis reveals growth trends and identifies slower months needing promotions.

## Recommendations:
 * Promote top-selling pizzas with discounts or combo offers to drive even higher volume.

 * Focus marketing on high-revenue categories and highlight most popular sizes.

 * Optimize kitchen & staff scheduling around peak order hours.

 * Adjust pricing and menu composition based on most & least profitable pizzas.

 * Track monthly trends proactively — plan campaigns or loyalty programs during off-peak months.

 * Invest in high-margin pizzas or premium variants that show consistent demand.

 ## Next Steps:
 * Implement regular reporting (weekly/monthly dashboards) using these KPIs.

 * Run A/B tests on promotional campaigns and measure impact.

 * Explore bundling most popular pizzas to maximize average order value.


✨ _Happy analyzing!_ ✨
