-- ============================================
-- SAKILA SQL BUSINESS CASE
-- ============================================
-- BUSINESS CONTEXT:
-- The company has requested key metrics to evaluate overall business performance.
-- The following questions aim to analyze revenue, customer value, and product performance.

-- 1. What is the total revenue generated per month?
-- This helps track sales trends over time and identify seasonality patterns.
SELECT strftime ('%Y', payment_date) AS Year, strftime ('%m', payment_date) AS Month, ROUND(SUM(amount),2) AS Revenue
FROM payment
GROUP BY Year, Month
ORDER BY Year, Month;
-- 2. What are the top 5 movie categories generating the highest revenue?
-- This helps identify the most profitable content categories.
SELECT c.name, ROUND(SUM(p.amount),2) AS revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON i.film_id = fc.film_id 
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY c.name 
ORDER BY revenue DESC
LIMIT 5;
-- 3. Which 10 movies had the highest number of rentals?
-- This helps determine the most popular titles among customers.
SELECT f.title,
COUNT(r.rental_id) AS total_rental
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY total_rental DESC
LIMIT 10;
-- 4. Who are the top 10 most valuable customers?
-- This helps identify high-value customers for retention and loyalty strategies.
SELECT c.first_name ||' '|| c.last_name AS Full_Name, ROUND(SUM(p.amount),2) AS Revenue
FROM customer c 
JOIN payment p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id
ORDER BY Revenue DESC
LIMIT 10;
-- 5. Top 3 movies by revenue within the 'Action' and 'Comedy' categories
-- This helps compare performance between key genres and identify top-performing titles.
WITH movie_revenue AS (SELECT f.title, c.name AS Category, ROUND(SUM(p.amount),2) AS Revenue
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id 
JOIN inventory i ON f.film_id = i.film_id 
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id
WHERE c.name IN ('Action', 'Comedy')
GROUP BY f.film_id, f.title, c.name)

SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY Category ORDER BY Revenue DESC) AS Ranking
FROM movie_revenue)
WHERE Ranking <= 3;
