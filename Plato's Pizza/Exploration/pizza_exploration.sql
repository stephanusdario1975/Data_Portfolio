-- Main query to combine all raw data
WITH
  pizza_detail AS(
  SELECT
    pizza_type_id,
    name,
    category,
    ingredients,
  FROM
    `tough-variety-418711.projects.dim_pizza_detail` ),

  pizza_price AS(
  SELECT
    pizza_id,
    pizza_type_id,
    size,
    price,
  FROM
    `tough-variety-418711.projects.dim_pizza_price` ),

  pizza_order AS(
  SELECT
    order_id,
    date,
    time,
  FROM
    `tough-variety-418711.projects.dim_pizza_order` ),

  pizza_order_detail AS(
  SELECT
    order_details_id,
    order_id,
    pizza_id,
    quantity,
  FROM
    `tough-variety-418711.projects.dwd_pizza_order_detail` ),

  joined_data AS(
  SELECT
    od.order_id,
    od.order_details_id,
    pp.pizza_type_id,
    pp.size,
    od.quantity,
    po.date,
    po.time,
    pp.price,
    pd.name,
    pd.category,
    pd.ingredients,
  FROM
    pizza_order_detail AS od
  LEFT JOIN
    pizza_order AS po
  ON
    od.order_id = po.order_id
  LEFT JOIN
    pizza_price AS pp
  ON
    pp.pizza_id = od.pizza_id
  LEFT JOIN
    pizza_detail AS pd
  ON
    pd.pizza_type_id = pp.pizza_type_id
  ORDER BY
    order_id ASC,
    order_details_id ASC)

SELECT
  order_id,
  order_details_id,
  pizza_type_id,
  size,
  quantity,
  FORMAT_DATE('%a', date) AS day_of_week,
  case when FORMAT_DATE('%A', date) = 'Monday' then 1
  when FORMAT_DATE('%A', date) = 'Tuesday' then 2
  when FORMAT_DATE('%A', date) = 'Wednesday' then 3
  when FORMAT_DATE('%A', date) = 'Thursday' then 4
  when FORMAT_DATE('%A', date) = 'Friday' then 5
  when FORMAT_DATE('%A', date) = 'Saturday' then 6
  when FORMAT_DATE('%A', date) = 'Sunday' then 7
  else null 
  end as day_order,
  date,
  time,
  EXTRACT(HOUR FROM time) as hour,
  price,
  name,
  category,
  ingredients,
FROM
  joined_data;

-- Query to analyze ingredient usage
WITH data as(WITH
  pizza_detail AS(
  SELECT
    pizza_type_id,
    name,
    category,
    ingredients,
  FROM
    `tough-variety-418711.projects.dim_pizza_detail` ),

  pizza_price AS(
  SELECT
    pizza_id,
    pizza_type_id,
    size,
    price,
  FROM
    `tough-variety-418711.projects.dim_pizza_price` ),

  pizza_order AS(
  SELECT
    order_id,
    date,
    time,
  FROM
    `tough-variety-418711.projects.dim_pizza_order` ),

  pizza_order_detail AS(
  SELECT
    order_details_id,
    order_id,
    pizza_id,
    quantity,
  FROM
    `tough-variety-418711.projects.dwd_pizza_order_detail` ),

  joined_data AS(
  SELECT
    od.order_id,
    od.order_details_id,
    pp.pizza_type_id,
    pp.size,
    od.quantity,
    po.date,
    po.time,
    pp.price,
    pd.name,
    pd.category,
    pd.ingredients,
  FROM
    pizza_order_detail AS od
  LEFT JOIN
    pizza_order AS po
  ON
    od.order_id = po.order_id
  LEFT JOIN
    pizza_price AS pp
  ON
    pp.pizza_id = od.pizza_id
  LEFT JOIN
    pizza_detail AS pd
  ON
    pd.pizza_type_id = pp.pizza_type_id
  ORDER BY
    order_id ASC,
    order_details_id ASC)

SELECT
  order_id,
  order_details_id,
  pizza_type_id,
  size,
  quantity,
  FORMAT_DATE('%a', date) AS day_of_week,
  case when FORMAT_DATE('%A', date) = 'Monday' then 1
  when FORMAT_DATE('%A', date) = 'Tuesday' then 2
  when FORMAT_DATE('%A', date) = 'Wednesday' then 3
  when FORMAT_DATE('%A', date) = 'Thursday' then 4
  when FORMAT_DATE('%A', date) = 'Friday' then 5
  when FORMAT_DATE('%A', date) = 'Saturday' then 6
  when FORMAT_DATE('%A', date) = 'Sunday' then 7
  else null 
  end as day_order,
  date,
  time,
  EXTRACT(HOUR FROM time) as hour,
  price,
  name,
  category,
  ingredients,
FROM
  joined_data
)

,exploded AS (
    SELECT 
order_id,
  order_details_id,
  pizza_type_id,
  size,
  quantity,
  day_of_week,
  day_order,
  date,
  time,
  EXTRACT(HOUR FROM time) as hour,
  price,
  name,
  category,
  ingredients,
        TRIM(ingredient) AS ingredient
    FROM data, 
    UNNEST(SPLIT(ingredients, ', ')) AS ingredient  -- Split ingredients into separate rows
)
SELECT 
    ingredient, 
    COUNT(DISTINCT order_details_id) AS total_used, 
    (COUNT(DISTINCT pizza_type_id) * 100.0) 
    / (SELECT COUNT(DISTINCT pizza_type_id) FROM exploded) AS menu_usage
FROM exploded
GROUP BY ingredient
ORDER BY total_used DESC, menu_usage DESC;

-- Query to analyze ingredients that used only once

WITH data as(WITH
  pizza_detail AS(
  SELECT
    pizza_type_id,
    name,
    category,
    ingredients,
  FROM
    `tough-variety-418711.projects.dim_pizza_detail` ),

  pizza_price AS(
  SELECT
    pizza_id,
    pizza_type_id,
    size,
    price,
  FROM
    `tough-variety-418711.projects.dim_pizza_price` ),

  pizza_order AS(
  SELECT
    order_id,
    date,
    time,
  FROM
    `tough-variety-418711.projects.dim_pizza_order` ),

  pizza_order_detail AS(
  SELECT
    order_details_id,
    order_id,
    pizza_id,
    quantity,
  FROM
    `tough-variety-418711.projects.dwd_pizza_order_detail` ),

  joined_data AS(
  SELECT
    od.order_id,
    od.order_details_id,
    pp.pizza_type_id,
    pp.size,
    od.quantity,
    po.date,
    po.time,
    pp.price,
    pd.name,
    pd.category,
    pd.ingredients,
  FROM
    pizza_order_detail AS od
  LEFT JOIN
    pizza_order AS po
  ON
    od.order_id = po.order_id
  LEFT JOIN
    pizza_price AS pp
  ON
    pp.pizza_id = od.pizza_id
  LEFT JOIN
    pizza_detail AS pd
  ON
    pd.pizza_type_id = pp.pizza_type_id
  ORDER BY
    order_id ASC,
    order_details_id ASC)

SELECT
  order_id,
  order_details_id,
  pizza_type_id,
  size,
  quantity,
  FORMAT_DATE('%a', date) AS day_of_week,
  case when FORMAT_DATE('%A', date) = 'Monday' then 1
  when FORMAT_DATE('%A', date) = 'Tuesday' then 2
  when FORMAT_DATE('%A', date) = 'Wednesday' then 3
  when FORMAT_DATE('%A', date) = 'Thursday' then 4
  when FORMAT_DATE('%A', date) = 'Friday' then 5
  when FORMAT_DATE('%A', date) = 'Saturday' then 6
  when FORMAT_DATE('%A', date) = 'Sunday' then 7
  else null 
  end as day_order,
  date,
  time,
  EXTRACT(HOUR FROM time) as hour,
  price,
  name,
  category,
  ingredients,
FROM
  joined_data
)

,exploded AS (
    SELECT 
order_id,
  order_details_id,
  pizza_type_id,
  size,
  quantity,
  day_of_week,
  day_order,
  date,
  time,
  EXTRACT(HOUR FROM time) as hour,
  price,
  name,
  category,
  ingredients,
        TRIM(ingredient) AS ingredient
    FROM data, 
    UNNEST(SPLIT(ingredients, ', ')) AS ingredient  -- Split ingredients into separate rows
)
SELECT 
    CASE 
        WHEN unique_pizza > 1 THEN 'More than once'
        ELSE 'Once'
    END AS usage_category,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM (SELECT ingredient FROM exploded GROUP BY ingredient) AS total) AS percentage
FROM (
    SELECT 
        ingredient, 
        COUNT(DISTINCT pizza_type_id) AS unique_pizza
    FROM exploded
    GROUP BY ingredient
) AS ingredient_counts
GROUP BY usage_category;

-- Query to analyze pizza menus category using unique ingredient
WITH data as(WITH
  pizza_detail AS(
  SELECT
    pizza_type_id,
    name,
    category,
    ingredients,
  FROM
    `tough-variety-418711.projects.dim_pizza_detail` ),

  pizza_price AS(
  SELECT
    pizza_id,
    pizza_type_id,
    size,
    price,
  FROM
    `tough-variety-418711.projects.dim_pizza_price` ),

  pizza_order AS(
  SELECT
    order_id,
    date,
    time,
  FROM
    `tough-variety-418711.projects.dim_pizza_order` ),

  pizza_order_detail AS(
  SELECT
    order_details_id,
    order_id,
    pizza_id,
    quantity,
  FROM
    `tough-variety-418711.projects.dwd_pizza_order_detail` ),

  joined_data AS(
  SELECT
    od.order_id,
    od.order_details_id,
    pp.pizza_type_id,
    pp.size,
    od.quantity,
    po.date,
    po.time,
    pp.price,
    pd.name,
    pd.category,
    pd.ingredients,
  FROM
    pizza_order_detail AS od
  LEFT JOIN
    pizza_order AS po
  ON
    od.order_id = po.order_id
  LEFT JOIN
    pizza_price AS pp
  ON
    pp.pizza_id = od.pizza_id
  LEFT JOIN
    pizza_detail AS pd
  ON
    pd.pizza_type_id = pp.pizza_type_id
  ORDER BY
    order_id ASC,
    order_details_id ASC)

SELECT
  order_id,
  order_details_id,
  pizza_type_id,
  size,
  quantity,
  FORMAT_DATE('%a', date) AS day_of_week,
  case when FORMAT_DATE('%A', date) = 'Monday' then 1
  when FORMAT_DATE('%A', date) = 'Tuesday' then 2
  when FORMAT_DATE('%A', date) = 'Wednesday' then 3
  when FORMAT_DATE('%A', date) = 'Thursday' then 4
  when FORMAT_DATE('%A', date) = 'Friday' then 5
  when FORMAT_DATE('%A', date) = 'Saturday' then 6
  when FORMAT_DATE('%A', date) = 'Sunday' then 7
  else null 
  end as day_order,
  date,
  time,
  EXTRACT(HOUR FROM time) as hour,
  price,
  name,
  category,
  ingredients,
FROM
  joined_data
)

,exploded AS (
    SELECT 
        order_id,
        order_details_id,
        pizza_type_id,
        size,
        quantity,
        day_of_week,
        day_order,
        date,
        time,
        EXTRACT(HOUR FROM time) AS hour,
        price,
        name,
        category,
        ingredients,
        TRIM(ingredient) AS ingredient
    FROM data, 
    UNNEST(SPLIT(ingredients, ', ')) AS ingredient  -- Split ingredients into separate rows
),
total_ingredients AS (
    SELECT COUNT(DISTINCT ingredient) AS total FROM exploded
),
unique_ingredients AS (
    SELECT 
        ingredient, 
        COUNT(DISTINCT pizza_type_id) AS unique_pizza
    FROM exploded
    GROUP BY ingredient
    HAVING COUNT(DISTINCT pizza_type_id) = 1  -- Only ingredients used once
)
SELECT 
    e.category,
    COUNT(DISTINCT i.ingredient) / t.total AS category_percentage
FROM unique_ingredients i
JOIN exploded e ON i.ingredient = e.ingredient
CROSS JOIN total_ingredients t
GROUP BY e.category, t.total;
