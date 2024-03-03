USE gdb0041;
select * from dim_customer where customer LIKE "%croma%";
select date_add('2021-04-01',interval 9 month);
select * from fact_sales_monthly where customer_code=90002002 and YEAR(date)=2021 order by date asc;
select * from fact_sales_monthly where customer_code=90002002 and get_fiscal_year(date)=2021 order by date desc;
select * from fact_sales_monthly where customer_code=90002002 and get_fiscal_year(date)=2021 and get_fiscal_quater(date)="Q4" order by date desc;
explain analyze select date,s.product_code,s.customer_code,sold_quantity,product,variant,
g.gross_price,gross_price*sold_quantity as gross_price_total from fact_sales_monthly as s
 join dim_product as p  on s.product_code=p.product_code join fact_gross_price as g 
 on s.product_code=g.product_code and s.fiscal_year=g.fiscal_year;
 select date, sum(sold_quantity*gross_price) as monthly_slaes from fact_sales_monthly s join fact_gross_price g on s.product_code=g.product_code and get_fiscal_year(s.date)=g.fiscal_year where customer_code in (90002002) group by s.date order by s.date asc;
 select get_fiscal_year(date) as FiscalYear, sum(sold_quantity*gross_price) as yearly_sales from fact_sales_monthly s join fact_gross_price g on s.product_code=g.product_code and get_fiscal_year(s.date)=g.fiscal_year where customer_code=90002002 group by get_fiscal_year(s.date) order by get_fiscal_year(s.date) asc;
 select * from dim_customer where customer LIKE "%amazon%" and market="India";
 with cte1 as (select s.date,s.fiscal_year,s.product_code,s.customer_code,s.sold_quantity,g.gross_price,
 g.gross_price*s.sold_quantity as gross_price_total, p.pre_invoice_discount_pct
 from fact_sales_monthly s join fact_gross_price g
 on s.product_code=g.product_code and s.fiscal_year=g.fiscal_year join fact_pre_invoice_deductions p 
 on s.customer_code=p.customer_code and s.fiscal_year=p.fiscal_year where s.fiscal_year=2021 limit 10000000000)
 select *, 
 gross_price_total - (gross_price_total*pre_invoice_discount_pct) as net_invoice_sales from cte1;
select s.date,s.fiscal_year,s.customer_code,s.market,
s.product_code,s.product,s.variant,s.sold_quantity,s.gross_price,
s.gross_price_total,s.pre_invoice_discount_pct, 
 gross_price_total - (gross_price_total*pre_invoice_discount_pct) as net_invoice_sales,
 (po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct from sales_pre_invoice_discount s 
 join fact_post_invoice_deductions po on
 s.date=po.date and 
 s.product_code=po.product_code and
 s.customer_code=po.customer_code;
 select * from sales_post_invoice_discount;
select c.customer, round(sum(net_sales)/1000000,2) net_sales_mln from net_sales n
join dim_customer c on n.customer_code=c.customer_code where n.fiscal_year=2021 and n.market="india"
group by c.customer order by net_sales_mln desc limit 5;
select market, round(sum(net_sales)/1000000,2) net_sales_mln from net_sales n where fiscal_year=2021
group by market order by net_sales_mln desc limit 5;
select product, round(sum(net_sales)/1000000,2) net_sales_mln from net_sales n where fiscal_year=2021
group by product order by net_sales_mln desc limit 5;
-- select c.market,c.region,sum(s.gross_price_total) from net_sales s join dim_customer c on s.customer_code=c.customer_code group by s.market
select
			c.market,
			c.region,
			round(sum(gross_price_total)/1000000,2) as gross_sales_mln
			from gross_sales s
			join dim_customer c
			on c.customer_code=s.customer_code
			where fiscal_year=2021
			group by market
			order by gross_sales_mln desc