                                                        -- ATLIQ HARDWARE PVT.LTD

/* PROBLEM STATEMENT NO-1
As a product owner, I want to generate a report of individual product sales(aggregated on a monthly basis at the product code level)
for corma India customer where FY=2021 so that I can track individual product sales and run further product analytics on it in excel.

The report should have the following field
1. Month
2. Product name
3. Variant
4. Sold Quantity
5. Gross Price Per Item
6. Gross Price Total*/
 
SELECT f.date,f.customer_code,
       p.product,p.variant,f.sold_quantity,g.gross_price,
       ROUND(f.sold_quantity*g.gross_price,2) as gross_price_total
FROM fact_sales_monthly f 
INNER JOIN dim_product p
ON f.product_code=p.product_code
INNER JOIN fact_gross_price g 
ON g.product_code=f.product_code AND 
   g.fiscal_year=get_fiscal_year(f.date)
WHERE customer_code=90002002 AND
      get_fiscal_year(date)=2021
ORDER BY date ASC;

-- PROBLEM STATEMENT NO-2:
/* As a product owner, I need an aggregate monthly sales report for Croma India customer 
so that I can track how much sales this customer is generating for AtliQ and manage our 
relationship accordingly.
The report should have the following fields:
1. Month
2. Total gross sales amount to Croma India this month*/

SELECT f.date, 
       SUM(ROUND(f.sold_quantity*g.gross_price,2)) AS gross_price_total
FROM fact_sales_monthly f 
INNER JOIN fact_gross_price g ON 
		   f.product_code=g.product_code AND
           g.fiscal_year=get_fiscal_year(f.date)
WHERE customer_code=90002002
GROUP BY f.date
ORDER BY f.date ASC;

-- PROBLEM STATEMENT NO-3:
/*  Create a stored procedure that can determine the market badge based 
on the following logic:
If total sold qty > 5 million that market is considered as Gold else it is Silver

Input will be:
--> market
--> fiscal year

Output will be: 
--> market badge*/

SELECT c.market,SUM(f.sold_quantity) AS total_sold_qty FROM fact_sales_monthly f 
INNER JOIN dim_customer c ON 
c.customer_code=f.customer_code
WHERE get_fiscal_year(f.date)=2021
GROUP BY c.market
ORDER BY c.market DESC;

-- PROBLEM STATEMENT NO-4:
/* As a product owner, I want a report for top markets, customers by net sales for a given financial year 
so that I can have a holistic view of our financial performance and can take any appropriate action to 
address any potential issues.
We will probably write stored procedure for this as we will need this report going forward as well.
1. Report for top markets
2. Report for top products
3. Report for top customers*/

/*WITH CTE1 AS(
SELECT f.date,f.customer_code,
       p.product,p.variant,f.sold_quantity,g.gross_price,
       ROUND(f.sold_quantity*g.gross_price,2) as gross_price_total,
       pre.pre_invoice_discount_pct
FROM fact_sales_monthly f 
INNER JOIN dim_product p
ON f.product_code=p.product_code
INNER JOIN dim_date dt 
ON dt.calander_date=f.date
INNER JOIN fact_pre_invoice_deductions pre 
ON pre.customer_code=f.customer_code AND
   pre.fiscal_year=f.fiscal_year
INNER JOIN fact_gross_price g 
ON g.product_code=f.product_code AND 
   g.fiscal_year=f.fiscal_year
WHERE
      get_fiscal_year(date)=2021)*/ -- This whole query has been used as a view now instead of using cte we can use view

SELECT *,
(1-pre_invoice_discount_pct)* gross_price_total AS net_invoice_sales,
(po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct
FROM sales_preinv_discount s
INNER JOIN fact_post_invoice_deductions po 
ON po.date=s.date AND
   po.product_code=s.product_code AND
   po.customer_code=s.customer_code;


-- to calculate net sales -->
							    SELECT *,
								(1-post_invoice_discount_pct)*net_invoice_sales AS net_sales
								FROM sales_postinv_discount;
                                
-- 1--> Top Market
SELECT 
    	    market, 
            round(sum(net_sales)/1000000,2) as net_sales_mln
	FROM gdb0041.net_sales
	where fiscal_year=2021
	group by market
	order by net_sales_mln desc
	limit 5;





 


