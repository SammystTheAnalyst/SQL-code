SELECT *
FROM KART..flipkart_com

---There are columns that are not essential for the analysis of the dataset, I have to delete them.
---That is 1.uniq_id 2.pid 3.image 4.is_FK_Advantage_product 5.description 6.product_specifications 

ALTER TABLE dbo.flipkart_com
DROP COLUMN uniq_id, pid, image, is_FK_Advantage_product, description, product_specifications



---1
---To get the total retail price, total discounted price based on product rating
SELECT product_rating, sum(retail_price) AS total_retail_price, sum(discounted_price) AS total_discounted_price
FROM KART..flipkart_com
WHERE product_rating IS NOT NULL AND retail_price IS NOT NULL AND discounted_price IS NOT NULL
GROUP BY brand, product_rating
ORDER BY product_rating DESC


---2
---To get the total retail price, total discounted price based on brand
SELECT brand, sum(retail_price) AS total_retail_price, sum(discounted_price) AS total_discounted_price
FROM KART..flipkart_com
WHERE brand IS NOT NULL AND retail_price IS NOT NULL AND discounted_price IS NOT NULL
GROUP BY brand
ORDER BY 2 DESC


---3
---To get Percentage_discount 
SELECT product_category_tree, retail_price, discounted_price, (discounted_price/retail_price)*100 AS Discount_percentage
FROM KART..flipkart_com
WHERE retail_price IS NOT NULL AND discounted_price IS NOT NULL
---GROUP BY product_category_tree
ORDER BY 3 DESC


---4
---To get the highest retail price, discount price and discount percentage per brand
SELECT brand, Max(retail_price) Highest_retail_price, MAX(discounted_price) AS Highest_discount_price, MAX((discounted_price/retail_price))*100 AS Highest_Discount_percentage
FROM KART..flipkart_com
WHERE retail_price IS NOT NULL AND discounted_price IS NOT NULL
GROUP BY brand
ORDER BY Highest_Discount_percentage DESC



---5
---To get the lowest retail price, discount price and discount percentage per brand
SELECT brand, MIN(retail_price) AS Lowest_retail_price, MIN(discounted_price) AS Lowest_discount_price, MIN((discounted_price/retail_price))*100 AS Lowest_Discount_percentage
FROM KART..flipkart_com
WHERE retail_price IS NOT NULL
GROUP BY brand
ORDER BY Lowest_Discount_percentage DESC


---6
------To get the count of Products per brand.
CREATE VIEW BrandProductCount AS
SELECT brand, COUNT(product_name) AS Count_of_BrandProducts
FROM KART..flipkart_com
WHERE brand IS NOT NULL
GROUP BY brand
---ORDER BY Count_of_BrandProducts DESC



---7
---To get Total retail and discounted prices per day using CTE
CREATE VIEW DailyTotals as 
WITH flipkart(DATE, retail_price, discounted_price)
AS
(
SELECT LEFT(crawl_timestamp, 10) AS DATE, retail_price, discounted_price
FROM KART..flipkart_com
WHERE retail_price IS NOT NULL AND discounted_price IS NOT NULL
)
SELECT *
, SUM(retail_price) OVER (PARTITION BY DATE) AS TotalDaily_RetailPrice, SUM(discounted_price) OVER (PARTITION BY DATE) AS TotalDaily_DiscountPrice
FROM flipkart
GROUP BY DATE, retail_price, discounted_price



---8
---To get the total retail and discounted prices per product rating and percentage discount uing CTE
CREATE VIEW DiscountPercentPerProductRating as
WITH RETVSDISC ---(product_rating)
AS
(
SELECT product_rating
, sum(retail_price) OVER (PARTITION BY product_rating) AS Rolling_retail_price, sum(discounted_price) OVER (PARTITION BY product_rating) AS Rolling_discounted_price
FROM KART..flipkart_com
WHERE product_rating IS NOT NULL AND retail_price IS NOT NULL AND discounted_price IS NOT NULL
GROUP BY product_rating, retail_price, discounted_price
---ORDER BY product_rating DESC
)
SELECT *, (Rolling_discounted_price/Rolling_retail_price)*100 AS Rolling_discount_percentage
FROM RETVSDISC


---9
---To get the total numbers
SELECT SUM(retail_price) AS TotalRetail, SUM(discounted_price) AS TotalDiscount, SUM(discounted_price)/SUM(retail_price)*100 AS TotalDiscountPercent
FROM KART..flipkart_com
WHERE retail_price IS NOT NULL AND discounted_price IS NOT NULL
ORDER BY 1