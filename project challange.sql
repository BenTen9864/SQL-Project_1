-- Q1 
select distinct market from dim_customer
where customer = "Atliq Exclusive"
and region = "APAC"



-- Q2 
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
select segment, count(distinct product_code) as "product_count"
from dim_product 
group by segment
order by product_count desc 

-- Q4 
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










