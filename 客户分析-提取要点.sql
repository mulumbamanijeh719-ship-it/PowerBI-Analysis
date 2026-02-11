-- 不同性别客户带来的总收入是多少？
SELECT
    gender,
    SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;


-- 使用了折扣但消费金额仍高于整体平均水平的客户有哪些？
SELECT
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (
      SELECT AVG(purchase_amount)
      FROM customer
  );


-- 平均商品评价最高的前 5 个商品是哪些？
SELECT
    item_purchased,
    ROUND(AVG(CAST(review_rating AS DECIMAL(10,2))), 2) AS avg_product_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_product_rating DESC
LIMIT 5;

-- 标准配送与加急配送的客户平均消费金额有何差异？
SELECT
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- 订阅用户是否比非订阅用户消费更多？
SELECT
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;

-- 折扣购买占比最高的前 5 个商品是哪些？
SELECT
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;


-- 根据历史购买次数将客户划分为新客、回头客和忠诚客户，并统计各类客户数量
WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT
    customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;

-- 在每个商品品类中，购买次数最多的前三个商品分别是哪些？
WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT
    category,
    item_rank,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3;
 
-- 高复购用户（历史购买次数超过 5 次）是否更有可能订阅服务？
SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- 不同年龄段客户的收入贡献情况如何？
SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

