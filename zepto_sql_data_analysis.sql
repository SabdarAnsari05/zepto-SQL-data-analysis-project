use zepto_SQL_project;

drop table if exists zepto;

CREATE TABLE zepto (
    sku_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BIT,
    quantity INT
);

INSERT INTO dbo.zepto (
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
)
SELECT
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
FROM dbo.zepto_v2;

select * from zepto_v2;
select * from zepto;

--Data Exploration

--count of rows
select count(*) from zepto;

--sample data
select top 10 *
from zepto;

--null values
select * from zepto
where name is null
or 
category is null
or
mrp is null
or 
discountPercent is null
or
discountedSellingPrice is null
or
weightInGms is null
or 
availableQuantity is null
or 
outOfStock is null
or 
quantity is null
;

--different product categories
select distinct category
from zepto
order by category;

--products in stock vs out of stock
select outOfStock, count(sku_id)
from zepto
group by outOfStock;

--product names present multiple times
select name, count(sku_id) as 'Number of SKUs'
from zepto
group by name
having count(sku_id) > 1
order by count(sku_id) desc;


--data cleaning

--products with price = 0
select * from zepto
where mrp = 0 or discountedSellingPrice = 0;

delete from zepto
where mrp=0;

--convert paise to rupees
update zepto
set mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

select mrp, discountedSellingPrice from zepto;

--Business Insight Queries

-- Q1. Find the top 10 best-value products based on the discount percentage.
select distinct top 10 
    name, 
    mrp, 
    discountPercent
from zepto
order by 
    discountPercent desc;

--Q2.What are the Products with High MRP but Out of Stock
select distinct name, mrp
from zepto
where outOfStock=1 and mrp > 300
order by mrp desc;

--Q3.Calculate Estimated Revenue for each category
select category,
SUM(discountedSellingPrice * availableQuantity) as total_revenue
from zepto
group by category
order by total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name, mrp, discountPercent  
from zepto
where mrp > 500 and discountPercent < 10
order by mrp desc, discountPercent desc;


-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select distinct top 5 category,
round(avg(discountPercent), 2) as avg_discount
from zepto
group by category
order by avg_discount desc;

-- Q6. Find the price per gram for products above 100g and sort by best value.
select distinct name, weightInGms, discountedSellingPrice,
round(discountedSellingPrice/weightInGms, 2) as price_per_gram
from zepto
where weightInGms >= 100
order by price_per_gram;


--Q7.Group the products into categories like Low, Medium, Bulk.
select distinct name, weightInGms,
case when weightInGms < 1000 then 'Low'
    when weightInGms < 5000 then 'Medium'
    else 'Bulk'
end as weight_category
from zepto;

--Q8.What is the Total Inventory Weight Per Category 
select category,
sum(weightInGms * availableQuantity) as total_weight
from zepto
group by category
order by total_weight;

