-- Gross Margin % by Category and Store, by Fiscal Year
SELECT 
    d.year AS fiscal_year,
    p.category,
    s.store_name,
    ROUND(
        (SUM(t.quantity * (t.unit_price - p.unit_cost))) / SUM(t.quantity * t.unit_price) * 100, 2
    ) AS gross_margin_pct
FROM sales_transactions t
JOIN dim_date d ON t.date = d.date
JOIN dim_product p ON t.product_id = p.product_id
JOIN dim_store s ON t.store_id = s.store_id
GROUP BY d.year, p.category, s.store_name
ORDER BY d.year, p.category, s.store_name;

-- CTE for Total Discount Value per Promotion and Sales Lift
WITH promo_discounts AS (
    SELECT 
        pr.promotion_id,
        pr.product_id,
        SUM(t.quantity * t.unit_price * pr.discount_pct) AS total_discount_value,
        SUM(t.quantity * t.unit_price) AS promo_sales
    FROM promotions pr
    JOIN sales_transactions t 
        ON pr.product_id = t.product_id
        AND t.date BETWEEN pr.start_date AND pr.end_date
    GROUP BY pr.promotion_id, pr.product_id
)
SELECT 
    promotion_id,
    product_id,
    total_discount_value,
    promo_sales,
    promo_sales - LAG(promo_sales) OVER (PARTITION BY product_id ORDER BY promotion_id) AS sales_lift
FROM promo_discounts;

-- Rolling 3-Month Average of Operating Costs per Store
SELECT 
    se.store_id,
    se.month,
    ROUND(
        AVG(se.rent + se.utilities + se.labor + se.other_costs) 
        OVER (PARTITION BY se.store_id ORDER BY se.month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
        2
    ) AS rolling_3m_operating_cost
FROM store_expenses se
ORDER BY se.store_id, se.month;

-- High-Revenue but Bottom-Quartile Margin Categories
WITH category_metrics AS (
    SELECT 
        p.category,
        SUM(t.quantity * t.unit_price) AS total_revenue,
        ROUND(
            (SUM(t.quantity * (t.unit_price - p.unit_cost))) / SUM(t.quantity * t.unit_price) * 100, 2
        ) AS gross_margin_pct
    FROM sales_transactions t
    JOIN dim_product p ON t.product_id = p.product_id
    GROUP BY p.category
),
quartiles AS (
    SELECT 
        category,
        total_revenue,
        gross_margin_pct,
        NTILE(4) OVER (ORDER BY gross_margin_pct) AS margin_quartile
    FROM category_metrics
)
SELECT category, total_revenue, gross_margin_pct
FROM quartiles
WHERE margin_quartile = 1
  AND total_revenue > (SELECT AVG(total_revenue) FROM category_metrics)
ORDER BY total_revenue DESC;






