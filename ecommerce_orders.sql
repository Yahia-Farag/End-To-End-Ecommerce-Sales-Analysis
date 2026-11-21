USE ecommerce;
GO

-- ============================================================================
-- 0. INITIAL DATA QUALITY AUDIT (Baseline Null Count)
-- ============================================================================
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS missing_segment,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_qty,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END) AS missing_discount_pct,
    SUM(CASE WHEN line_total IS NULL THEN 1 ELSE 0 END) AS missing_line_total,
    SUM(CASE WHEN returned IS NULL THEN 1 ELSE 0 END) AS missing_returned
FROM ecommerce_orders;

-- ============================================================================
-- 1. ORDER-LEVEL IDENTIFIERS & DATES
-- ============================================================================

-- Impute missing order_date from line items sharing the same order_id
UPDATE t1
SET t1.order_date = t2.order_date
FROM ecommerce_orders t1 
JOIN ecommerce_orders t2
    ON t1.order_id = t2.order_id
WHERE t1.order_date IS NULL
  AND t2.order_date IS NOT NULL;

-- Impute missing order_id using matching customer_id and order_date
UPDATE t1
SET t1.order_id = t2.order_id
FROM ecommerce_orders t1 
JOIN ecommerce_orders t2
    ON t1.customer_id = t2.customer_id
   AND t1.order_date = t2.order_date 
WHERE t1.order_id IS NULL
  AND t2.order_id IS NOT NULL;

-- ============================================================================
-- 2. CUSTOMER DIMENSION CLEANING (ID, Name, Segment, Channel)
-- ============================================================================

-- Impute missing customer_id from line items sharing the same order_id
UPDATE t1
SET t1.customer_id = t2.customer_id
FROM ecommerce_orders t1
JOIN ecommerce_orders t2
    ON t1.order_id = t2.order_id
WHERE t1.customer_id IS NULL
  AND t2.customer_id IS NOT NULL;

-- Standardize customer names using the most frequent spelling per customer_id
WITH CleanCustomerNames AS (
    SELECT 
        customer_id,
        TRIM(customer) AS clean_name,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM ecommerce_orders
    WHERE customer_id IS NOT NULL 
      AND customer IS NOT NULL
    GROUP BY customer_id, TRIM(customer)
)
UPDATE t
SET t.customer = c.clean_name
FROM ecommerce_orders t
JOIN CleanCustomerNames c
    ON t.customer_id = c.customer_id
WHERE c.rn = 1
  AND (t.customer IS NULL OR t.customer <> c.clean_name);

-- Fix specific remaining camelCase/typo anomalies in customer names
UPDATE ecommerce_orders
SET customer = CASE customer_id
    WHEN 96  THEN 'Kai Bauer'
    WHEN 142 THEN 'Wren Park'
END
WHERE customer_id IN (96, 142);

-- Standardize customer segment typos into 5 core categories
UPDATE ecommerce_orders
SET segment = CASE 
    WHEN TRIM(segment) IN ('Loyal', 'Loayl', 'Lyoal', 'Loyla', 'oLyal') THEN 'Loyal'
    WHEN TRIM(segment) IN ('Champion', 'Champino', 'Chmapion', 'Champoin', 'Chapmion', 'Chamipon', 'hCampion', 'Cahmpion') THEN 'Champion'
    WHEN TRIM(segment) IN ('Regular', 'eRgular', 'Regluar', 'Regulra', 'Rgeular', 'Regualr') THEN 'Regular'
    WHEN TRIM(segment) IN ('New', 'Nwe', 'eNw') THEN 'New'
    WHEN TRIM(segment) IN ('At-Risk', 'AtR-isk', 'A-tRisk') THEN 'At-Risk'
    ELSE segment
END
WHERE segment IS NOT NULL;

-- Impute missing segment values using customer_id
UPDATE t1
SET t1.segment = t2.segment
FROM ecommerce_orders t1
JOIN ecommerce_orders t2
    ON t1.customer_id = t2.customer_id
WHERE t1.segment IS NULL
  AND t2.segment IS NOT NULL;

-- Standardize acquisition channel typos into 6 core channels
UPDATE ecommerce_orders
SET channel = CASE 
    WHEN TRIM(channel) IN ('Referral', 'Referrla', 'Rfeerral', 'Referarl', 'Reefrral', 'Refreral') THEN 'Referral'
    WHEN TRIM(channel) IN ('Paid Search', 'aPid Search', 'Paid Saerch', 'Padi Search', 'Paid Serach', 'Paid Searhc', 'Pai dSearch', 'PaidS earch', 'Piad Search', 'Paid eSarch') THEN 'Paid Search'
    WHEN TRIM(channel) IN ('Direct', 'Dircet', 'iDrect', 'Diretc', 'Dierct', 'Driect') THEN 'Direct'
    WHEN TRIM(channel) IN ('Email', 'Emali', 'Eamil', 'Emial', 'mEail') THEN 'Email'
    WHEN TRIM(channel) IN ('Social', 'Soical', 'Socila', 'oScial', 'Scoial') THEN 'Social'
    WHEN TRIM(channel) IN ('Organic', 'rOganic', 'Orgainc', 'Oragnic', 'Ogranic', 'Orgnaic', 'Organci') THEN 'Organic'
    ELSE channel
END
WHERE channel IS NOT NULL;

-- Impute missing channel values using customer_id
UPDATE t1
SET t1.channel = t2.channel
FROM ecommerce_orders t1
JOIN ecommerce_orders t2
    ON t1.customer_id = t2.customer_id
WHERE t1.channel IS NULL
  AND t2.channel IS NOT NULL;

-- ============================================================================
-- 3. PRODUCT DIMENSION CLEANING (ID, Product Name, Category)
-- ============================================================================

-- Standardize product names using the most frequent spelling per product_id
WITH CleanProductNames AS (
    SELECT 
        product_id,
        TRIM(product) AS clean_product,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM ecommerce_orders
    WHERE product_id IS NOT NULL
      AND product IS NOT NULL
    GROUP BY product_id, TRIM(product)
)
UPDATE t
SET t.product = c.clean_product
FROM ecommerce_orders t
JOIN CleanProductNames c
    ON t.product_id = c.product_id
WHERE c.rn = 1
  AND (t.product IS NULL OR t.product <> c.clean_product);

-- Impute missing product_id using standardized product names
UPDATE t1
SET t1.product_id = t2.product_id
FROM ecommerce_orders t1
JOIN ecommerce_orders t2
    ON TRIM(t1.product) = TRIM(t2.product)
WHERE t1.product_id IS NULL
  AND t2.product_id IS NOT NULL;

-- Standardize product category typos into 6 core categories
UPDATE ecommerce_orders
SET category = CASE 
    WHEN TRIM(category) IN ('Apparel', 'pAparel', 'Apaprel', 'Appaerl', 'Apprael') THEN 'Apparel'
    WHEN TRIM(category) IN ('Electronics', 'Elcetronics', 'Electronisc', 'Electroincs', 'Eletcronics', 'Electroncis', 'Electornics', 'Electrnoics', 'lEectronics', 'Elecrtonics') THEN 'Electronics'
    WHEN TRIM(category) IN ('Home', 'oHme', 'Hoem', 'Hmoe') THEN 'Home'
    WHEN TRIM(category) IN ('Toys', 'Tosy', 'oTys', 'Tyos') THEN 'Toys'
    WHEN TRIM(category) IN ('Beauty', 'eBauty', 'Beatuy', 'Beuaty', 'Beauyt', 'Baeuty') THEN 'Beauty'
    WHEN TRIM(category) IN ('Sports', 'pSorts', 'Sporst', 'Soprts', 'Sprots') THEN 'Sports'
    ELSE category
END
WHERE category IS NOT NULL;

-- Impute missing category values using product_id
UPDATE t1
SET t1.category = t2.category
FROM ecommerce_orders t1
JOIN ecommerce_orders t2
    ON t1.product_id = t2.product_id
WHERE t1.category IS NULL
  AND t2.category IS NOT NULL;

-- ============================================================================
-- 4. FINANCIAL METRICS & RETURN STATUS
-- ============================================================================

-- Round currency columns to 2 decimal places for precision consistency
UPDATE ecommerce_orders
SET unit_price = ROUND(unit_price, 2),
    line_total = ROUND(line_total, 2);

-- Recalculate missing discount_pct from quantity, unit_price, and line_total
UPDATE ecommerce_orders
SET discount_pct = ROUND((1 - (line_total / (unit_price * quantity))) * 100.0, 0)
WHERE discount_pct IS NULL
  AND line_total IS NOT NULL
  AND unit_price IS NOT NULL
  AND quantity IS NOT NULL;

-- Recalculate missing quantity (handles both 0% and >0% discount orders)
UPDATE ecommerce_orders
SET quantity = ROUND(line_total / (unit_price * (1 - discount_pct / 100.0)), 2)
WHERE quantity IS NULL
  AND line_total IS NOT NULL
  AND unit_price IS NOT NULL
  AND discount_pct IS NOT NULL;

-- Recalculate missing or truncated integer unit_price values
UPDATE ecommerce_orders
SET unit_price = ROUND(line_total / (quantity * (1 - discount_pct / 100.0)), 2)
WHERE (unit_price IS NULL OR unit_price = ROUND(unit_price, 0))
  AND quantity IS NOT NULL
  AND line_total IS NOT NULL
  AND discount_pct IS NOT NULL;

-- Recalculate missing line_total (handles both 0% and >0% discount orders)
UPDATE ecommerce_orders
SET line_total = ROUND(quantity * unit_price * (1 - discount_pct / 100.0), 2)
WHERE line_total IS NULL
  AND quantity IS NOT NULL
  AND unit_price IS NOT NULL
  AND discount_pct IS NOT NULL;

-- Default NULL return flags to 0 (non-returned)
UPDATE ecommerce_orders
SET returned = 0
WHERE returned IS NULL;

-- ============================================================================
-- 5. DEDUPLICATION & FINAL QUALITY CHECK
-- ============================================================================

-- Remove exact duplicate line items while retaining the first occurrence
WITH RemoveDuplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_date, order_id, customer_id, customer, segment, channel,
                            product_id, product, category, quantity, unit_price, discount_pct, line_total, returned
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM ecommerce_orders
)
DELETE FROM RemoveDuplicates
WHERE rn > 1;

-- Final audit to verify clean state before modeling
SELECT
    COUNT(*) AS final_total_rows,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS missing_segment,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_qty,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END) AS missing_discount_pct,
    SUM(CASE WHEN line_total IS NULL THEN 1 ELSE 0 END) AS missing_line_total,
    SUM(CASE WHEN returned IS NULL THEN 1 ELSE 0 END) AS missing_returned
FROM ecommerce_orders;
GO