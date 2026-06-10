
------------===============////Total Number of Customer By State
Select
	customer_city,
	customer_state,
	COUNT(*) As Total_Customer
From
	olist_customers_dataset$

Group By
	customer_city,
	customer_state
Order By
	Total_Customer Desc;
------------===============////Total Number of Customer By State

------------===============////Total Number of Orders in each Day
Select 
	Cast(order_purchase_timestamp As Date) As Date,
	COUNT(*) As TotalOrder
From 
	olist_orders_dataset$
Group By
	Cast(order_purchase_timestamp As Date)
Order By
	COUNT(*) Desc;
------------===============////Total Number of Orders in each Day

------------===============////Total Number of Orders in each Day with Stored Procedure
Create Procedure See_Order_By_DateDesc
(
	@StartdateDesc Date,
	@EnddateDesc Date
)
As
Begin
	Select 
		Cast(order_purchase_timestamp As Date) As Date,
		COUNT(*) As TotalOrder
	From 
		olist_orders_dataset$
	Where
		Cast(order_purchase_timestamp As Date) Between @StartdateDesc and @EnddateDesc
	Group By
		Cast(order_purchase_timestamp As Date)
	Order By
		COUNT(*) Desc
End;

--===================
Execute See_Order_By_DateDesc'2017-11-24', '2017-12-26';
------------===============////Total Number of Orders in each Day with Stored Procedure

------------===============////Each Product Perfomence By Category
Select
	pd.product_category_name,
	Sum(oid.price) As Total_Revenue,
	Count(ord.review_score) As Total_Reviews,
	Count(oid.order_id) As Total_Orders,
	Avg(ord.review_score) Avg_Score
From
	olist_order_items_dataset$ oid

Join olist_products_dataset$ pd On oid.product_id = pd.product_id
Join olist_order_reviews_dataset$ ord On oid.order_id = ord.order_id

Group By
	pd.product_category_name
Order By
	Total_Revenue Desc;
------------===============////Each Product Perfomence By Category

------------===============////Each Product Perfomence By Category that also Have Highest 1 Star Review
SELECT 
    pd.product_category_name,
    SUM(oid.price) AS Total_Revenue,
    COUNT(DISTINCT oid.order_id) AS Total_Orders,
    COUNT(ord.review_score) AS Total_Reviews,
    AVG(CAST(ord.review_score AS Float)) AS Avg_Score,
    COUNT(CASE WHEN ord.review_score = 1 THEN 1 END) AS Total_1_Star_Reviews,
    
    -- THE CRUCIAL METRIC: What % of total reviews are 1-star?
    (CAST(COUNT(CASE WHEN ord.review_score = 1 THEN 1 END) AS Float) / 
     NULLIF(COUNT(ord.review_score), 0)) * 100 AS One_Star_Rate_Percentage
FROM 
    olist_order_items_dataset$ oid
JOIN 
    olist_products_dataset$ pd ON oid.product_id = pd.product_id
JOIN 
    olist_order_reviews_dataset$ ord ON oid.order_id = ord.order_id
GROUP BY 
    pd.product_category_name
-- FILTER: Only look at established categories making good revenue (removes low-sale outliers)
HAVING 
    SUM(oid.price) > 50000 
ORDER BY 
    One_Star_Rate_Percentage DESC; -- Brings high-revenue, high-failure categories straight to the top
------------===============////Each Product Perfomence By Category that also Have Highest 1 Star Review

------------===============////Each Product Perfomence and Rateing By Category
Select
	pd.product_category_name,
	Sum(oid.price) As Total_Revenue,
	Count(ord.review_score) As Total_Reviews,
	Avg(ord.review_score) Avg_Score,
	COUNT(CASE WHEN ord.review_score = 1 THEN 1 END) AS Total_1_Star_Reviews,
	COUNT(CASE WHEN ord.review_score = 2 THEN 1 END) AS Total_2_Star_Reviews,
	COUNT(CASE WHEN ord.review_score = 3 THEN 1 END) AS Total_3_Star_Reviews,
	COUNT(CASE WHEN ord.review_score = 4 THEN 1 END) AS Total_4_Star_Reviews,
	COUNT(CASE WHEN ord.review_score = 5 THEN 1 END) AS Total_5_Star_Reviews
From
	olist_order_items_dataset$ oid

Join olist_products_dataset$ pd On oid.product_id = pd.product_id
Join olist_order_reviews_dataset$ ord On oid.order_id = ord.order_id

Group By
	pd.product_category_name
Order By
	Total_Revenue Desc;
----------===============////Each Product Perfomence and Rateing By Category

----------===============////Average Product Cost and Profit Margin
SELECT 
    pd.product_category_name,
    AVG(opd.payment_value) AS Avg_Total_Amount_Paid,
    AVG(oid.price) AS Avg_Item_Base_Price,
    -- Calculates the true average gap across the entire category population
    AVG(opd.payment_value - oid.price) AS Avg_Financial_Gap
FROM 
    olist_order_payments_dataset$ opd
JOIN 
    olist_order_items_dataset$ oid ON opd.order_id = oid.order_id
JOIN 
    olist_products_dataset$ pd ON oid.product_id = pd.product_id
GROUP BY 
    pd.product_category_name
ORDER BY 
    Avg_Financial_Gap DESC;
----------===============////Average Product Cost and Profit Margin

----------===============////Delivery Diff of every Order
Select 
	order_id,
	order_delivered_customer_date,
	order_estimated_delivery_date,
	DATEDIFF(DD , order_delivered_customer_date, order_estimated_delivery_date) As 'Delivere Perfomance'
From 
	olist_orders_dataset$
Where 
	order_status = 'delivered';

Select 
	order_id,
	order_delivered_customer_date,
	order_estimated_delivery_date,
	Year(order_purchase_timestamp) As Year,
	Month(order_purchase_timestamp) As Month,
	DATEDIFF(DD , order_delivered_customer_date, order_estimated_delivery_date) As 'Delivere Perfomance'
From 
	olist_orders_dataset$
Where 
	order_status = 'delivered';
----------===============////Delivery Diff of every Order

SELECT
    YEAR(CAST(order_purchase_timestamp AS datetime)) AS order_year,
    MONTH(CAST(order_purchase_timestamp AS datetime)) AS order_month,
    -- Kept strictly as written: order_estimated_delivery_date minus order_delivered_customer_date
    AVG(CAST(
        DATEDIFF(day, 
            CAST(order_delivered_customer_date AS datetime), 
            CAST(order_estimated_delivery_date AS datetime)
        ) AS float
    )) AS date_diff

FROM 
    olist_orders_dataset$

WHERE 
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL 
    AND order_delivered_customer_date <> ''

GROUP BY 
    YEAR(CAST(order_purchase_timestamp AS datetime)), 
    MONTH(CAST(order_purchase_timestamp AS datetime))

ORDER BY 
    order_year, 
    order_month;

----------===============////Average Delivery Performece
Select
	AVG(DaysDifference)
From
	(Select 
		DATEDIFF(day, CAST(order_delivered_customer_date As Date), CAST(order_estimated_delivery_date As Date)) AS DaysDifference
	From 
		olist_orders_dataset$
	Where
		order_status = 'delivered') As Delivary_Diff;
----------===============////Average Delivery Performece

----------===============////Average Late Delivery Performece
Select
	AVG(DaysDifference)
From
	(Select 
		DATEDIFF(day, CAST(order_delivered_customer_date As Date), CAST(order_estimated_delivery_date As Date)) AS DaysDifference
	From 
		olist_orders_dataset$
	Where
		DATEDIFF(day, CAST(order_delivered_customer_date As Date), CAST(order_estimated_delivery_date As Date)) < 0 and order_status = 'delivered') As Agerage_Delay;
----------===============////Average Late Delivery Performece

----------===============////Days Difference by Each Month of Year
	Select
		YEAR(CAST(order_purchase_timestamp AS datetime)) AS order_year,
		MONTH(CAST(order_purchase_timestamp AS datetime)) AS order_month,
		AVG(DaysDifference) As Date_Diff
	From
		(Select 
			DATEDIFF(day, CAST(order_delivered_customer_date As Date), CAST(order_estimated_delivery_date As Date)) AS DaysDifference,
			order_purchase_timestamp
		From 
			olist_orders_dataset$
		Where
			order_status = 'delivered') As Agerage_Delay

	Group By
		YEAR(CAST(order_purchase_timestamp AS datetime)),
		MONTH(CAST(order_purchase_timestamp AS datetime));
----------===============////Days Difference by Each Month of Year

----------===============////Days Difference of Each Month of Year and The Average of Each Month of Year
SELECT 
    YEAR(CAST(ood.order_purchase_timestamp AS datetime)) AS order_year,
    MONTH(CAST(ood.order_purchase_timestamp AS datetime)) AS order_month,
    AVG(DATEDIFF(day, CAST(ood.order_delivered_customer_date AS Date), CAST(ood.order_estimated_delivery_date AS Date))) AS DaysDifference,
    -- Pulls the safely calculated metric from our joined table below
    max(Monthly_Diff.Avg_Monthly_Diff) AS Historical_Month_Baseline
FROM 
    olist_orders_dataset$ ood

LEFT JOIN (
    -- Clean Subquery returning an aggregated matrix safely
    SELECT 
        MONTH(CAST(order_purchase_timestamp AS datetime)) AS sub_month,
        AVG(DATEDIFF(day, CAST(order_delivered_customer_date AS Date), CAST(order_estimated_delivery_date AS Date))) AS Avg_Monthly_Diff
    FROM 
        olist_orders_dataset$
    WHERE order_status = 'delivered'
    GROUP BY MONTH(CAST(order_purchase_timestamp AS datetime))
) Monthly_Diff ON MONTH(CAST(ood.order_purchase_timestamp AS datetime)) = Monthly_Diff.sub_month

WHERE
    ood.order_status = 'delivered'
GROUP BY
    YEAR(CAST(ood.order_purchase_timestamp AS datetime)),
    MONTH(CAST(ood.order_purchase_timestamp AS datetime))
ORDER BY 
    order_year, 
    order_month;
----------===============////Days Difference of Each Month of Year and The Average of Each Month of Year

SELECT
    order_id,
    order_year,
    order_month,
    actual_delivery_date,
    estimated_delivery_date,
    date_diff,
    avg_month_diff
FROM (
    SELECT
        order_id,
        order_year,
        order_month,
        actual_delivery_date,
        estimated_delivery_date,
        
        -- Raw difference for this specific order
        DATEDIFF(day, actual_delivery_date, estimated_delivery_date) AS date_diff,
        
        -- Monthly average baseline calculated across the year/month window
        AVG(CAST(DATEDIFF(day, actual_delivery_date, estimated_delivery_date) AS float)) 
            OVER (PARTITION BY order_year, order_month) AS avg_month_diff
    FROM (
        SELECT
            order_id,
            -- T-SQL equivalents for DATE_PART
            YEAR(CAST(order_purchase_timestamp AS datetime)) AS order_year,
            MONTH(CAST(order_purchase_timestamp AS datetime)) AS order_month,
            CAST(order_delivered_customer_date AS datetime) AS actual_delivery_date,
            CAST(order_estimated_delivery_date AS datetime) AS estimated_delivery_date
        FROM olist_orders_dataset$
        WHERE order_status = 'delivered'
          AND order_delivered_customer_date IS NOT NULL
          AND order_delivered_customer_date <> ''
    ) t
) s
-- Filters out the high performers, leaving only individual orders that lagged behind the monthly average
WHERE date_diff < avg_month_diff
ORDER BY 
    order_year, 
    order_month;
