-- Q1 Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
select distinct market from dim_customer
where customer = "Atliq Exclusive"
and region = "APAC"



-- Q2 What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields
with cte_1 as (
select count(distinct product_code) as 'unique_products_2020'
from fact_sales_monthly
where year(date_add(date, interval 4 month))=2020), 

cte_2 as (select count(distinct product_code) as 'unique_products_2021'
from fact_sales_monthly
where year(date_add(date, interval 4 month))=2021)

select unique_products_2020, 
unique_products_2021, 
((unique_products_2021-unique_products_2020)*100/unique_products_2020) as "percentage_chg"
from cte_1, cte_2


-- Q3 
-- Provide a report with all the unique product counts 
-- for each segment and sort them in descending order of product counts. 
-- The final output contains 2 fields

select segment, count(distinct product_code) as "product_count"
from dim_product 
group by segment
order by product_count desc 

-- Q4 
-- Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
-- The final output contains these fields
with cte1 as (SELECT
d.segment,
COUNT(DISTINCT d.product_code) AS "product_count_2020"
FROM dim_product d
JOIN fact_sales_monthly f
using (product_code)
WHERE fiscal_year(date) = 2020
GROUP BY d.segment),
cte2 as (SELECT
d.segment,
COUNT(DISTINCT d.product_code) AS "product_count_2021"
FROM dim_product d
JOIN fact_sales_monthly f
using (product_code)
WHERE fiscal_year(date) = 2021
GROUP BY d.segment)
select cte1.segment, 
product_count_2020, 
product_count_2021, 
product_count_2021- product_count_2020 as "difference" 
from cte1, cte2
where cte1.segment = cte2.segment
order by difference desc

-- Q5 
-- Get the products that have the highest and lowest manufacturing costs. 
-- The final output should contain these fields
select 
d.product_code, 
product, 
manufacturing_cost
from dim_product d 
join fact_manufacturing_cost f 
on d.product_code = f.product_code
where manufacturing_cost in (
select max(manufacturing_cost) from  fact_manufacturing_cost
union
select min(manufacturing_cost) from  fact_manufacturing_cost 
)


-- Q6 
-- Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct 
-- for the fiscal year 2021 and in the Indian market. 
-- The final output contains these fields
select 
d.customer_code, customer, round(avg(pre_invoice_discount_pct),4) as "average_discount_percentage"
from dim_customer d 
join fact_pre_invoice_deductions f 
on d.customer_code = f.customer_code
where fiscal_year = 2021 and market = 'india'
group by d.customer_code, customer
order by average_discount_percentage desc 
limit 5 

-- Q7 
-- Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. 
-- This analysis helps to get an idea of low and high-performing months and take strategic decisions
select
year(date) as "year", 
month(date) as "month", 
round(sum(sold_quantity*gross_price),2) as "gross_sales"
from fact_gross_price fg
join fact_sales_monthly fs 
on fg.product_code = fs.product_code
group by year(date), month(date)
order by year desc, gross_sales desc 

-- Q8 
-- In which quarter of 2020, got the maximum total_sold_quantity? 
-- The final output contains these fields sorted by the total_sold_quantity

select Quarter, sum(sold_quantity) as "total_sold_quantity" from 
(select*,
case 
when month(date_add(date, interval 4 month)) between 1 and 3  then "Q1"
when month(date_add(date, interval 4 month)) between 4 and 6 then "Q2"
when month(date_add(date, interval 4 month)) between 7 and 9 then "Q3"
else "Q4"
end as Quarter
from fact_sales_monthly) tab
where fiscal_year = 2020
group by Quarter
order by total_sold_quantity desc

-- Q9 
-- Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
-- The final output contains these fields


with cte as (
select
channel, 
round(sum(sold_quantity*gross_price)/1000000,2) as "gross_sales_mln"
from dim_customer d 
join fact_sales_monthly f 
on d.customer_code = f.customer_code
join fact_gross_price fg 
on fg.product_code = f.product_code
where f.fiscal_year=2021
group by channel ) 
select*, 
round(gross_sales_mln*100/sum(gross_sales_mln) over(),2)  as "percentage"
from cte 
order by percentage desc

-- Q10 
-- Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
-- The final output contains these fields

select*from 
(with cte as (
select
division, d.product_code, 
product, sum(sold_quantity) as "total_sold_quantity"
from dim_product d
join fact_sales_monthly f
on d.product_code = f.product_code
where fiscal_year = 2021
group by division, d.product_code, product ) 
select*,
dense_rank() over(partition by division order by total_sold_quantity desc) as "rank_order"
from cte) tab
where rank_order <=3






