SELECT *
FROM invoice

-- DATA ANALYSIS QUESTIONS AND QUERIES:

-- 1. Most Senior Employee

SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name, title
FROM employee
WHERE title = 'Senior General Manager'

-- 2. Countries with most invoices + Number of Invoices

SELECT MAX(DISTINCT(billing_country)) AS Country
FROM invoice

SELECT MAX(DISTINCT(billing_country)) AS Country, COUNT(invoice_id) AS Invoices
FROM invoice
WHERE billing_country = 'USA'

-- 3. Top 3 Values of Total Invoices

SELECT TOP 3 *
FROM invoice
ORDER BY total DESC

-- 4. City with highest sum of invoice totals

SELECT TOP 1 billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC

-- 5. Best Customer

SELECT inv.customer_id, CONCAT(cus.first_name, ' ', cus.last_name) AS full_name, SUM(inv.total) AS total_spent
FROM invoice inv
JOIN customer cus
ON cus.customer_id = inv.customer_id
GROUP BY inv.customer_id, CONCAT(cus.first_name, ' ', cus.last_name)
ORDER BY SUM(inv.total) DESC

-- 6. Find the email, full name and genre of all rock music listeners. Alphabetically ordered from A-Z

SELECT DISTINCT cus.email, CONCAT(cus.first_name, ' ', cus.last_name) AS full_name, gen.name
FROM customer cus
JOIN invoice inv
ON cus.customer_id = inv.customer_id
JOIN invoice_line invline
ON invline.invoice_id = inv.invoice_id
JOIN track tra
ON tra.track_id = invline.track_id
JOIN genre gen
ON gen.genre_id = tra.genre_id
WHERE gen.name = 'Rock'
ORDER BY full_name ASC

-- Find the artists who have written the most Rock Music. Artist name + count of total track for TOP 10

SELECT art.artist_id, art.name, COUNT(tra.track_id) AS tracks
FROM track tra
JOIN album alb1
ON tra.album_id = alb1.album_id
JOIN artist art
ON art.artist_id = alb1.artist_id
JOIN genre gen
ON gen.genre_id = tra.genre_id
WHERE gen.name LIKE 'Rock'
GROUP BY art.name, art.artist_id
ORDER BY tracks DESC

-- Find track names with > AVG song length. Present as track name and length. Order by length (Longest-Shortest)

SELECT tra.name, tra.milliseconds AS length
FROM track tra
WHERE tra.milliseconds > (SELECT AVG(tra.milliseconds) FROM track tra)
ORDER BY length DESC

-- Find the amount spent by each customer on the top artist

WITH sales AS (
SELECT TOP 1 art.artist_id, art.name, SUM(invl.unit_price*invl.quantity) AS total_sales
FROM artist art
JOIN album alb
ON art.artist_id = alb.artist_id
JOIN track tra
ON tra.album_id = alb.album_id
JOIN invoice_line invl
ON invl.track_id = tra.track_id
GROUP BY art.artist_id, art.name
ORDER BY total_sales DESC
)
SELECT cus.customer_id, CONCAT(cus.first_name, ' ', cus.last_name) AS full_name, sales.name, SUM(invl.unit_price*invl.quantity) AS total_sales
FROM customer cus
JOIN invoice inv
ON inv.customer_id = cus.customer_id
JOIN invoice_line invl
ON invl.invoice_id = inv.invoice_id
JOIN track tra
ON tra.track_id = invl.track_id
JOIN album alb
ON alb.album_id = tra.album_id
JOIN sales
ON sales.artist_id = alb.artist_id
GROUP BY cus.customer_id, CONCAT(cus.first_name, ' ', cus.last_name), sales.name
ORDER BY total_sales DESC

-- Find out the most popular music genre (most purchases) for every country

WITH popgen AS (
SELECT cus.country, gen.name, gen.genre_id, COUNT(invline.quantity) AS purchases, ROW_NUMBER() OVER (PARTITION BY cus.country ORDER BY COUNT(invline.quantity) DESC) AS Rows
FROM invoice inv
JOIN invoice_line invline
ON invline.invoice_id = inv.invoice_id
JOIN track tra
ON tra.track_id = invline.track_id
JOIN genre gen
ON gen.genre_id = tra.genre_id
JOIN customer cus
ON cus.customer_id = inv.customer_id
GROUP BY cus.country, gen.name, gen.genre_id
)
SELECT * 
FROM popgen
WHERE Rows <= 1
ORDER BY purchases DESC

-- Find the customers that have spent the most on music for every country. Return country, customer name, customer id, and amount spent

WITH big_spenders AS (
SELECT cus.country, cus.customer_id, CONCAT(cus.first_name, ' ', cus.last_name) AS full_name, COUNT(inv.total) AS money_spent, ROW_NUMBER() OVER (PARTITION BY cus.country ORDER BY COUNT(inv.total) DESC) AS Rows
FROM invoice inv
JOIN invoice_line invline
ON invline.invoice_id = inv.invoice_id
JOIN track tra
ON tra.track_id = invline.track_id
JOIN genre gen
ON gen.genre_id = tra.genre_id
JOIN customer cus
ON cus.customer_id = inv.customer_id
GROUP BY cus.country, cus.customer_id, CONCAT(cus.first_name, ' ', cus.last_name)
)
SELECT * 
FROM big_spenders
WHERE Rows <= 1
ORDER BY big_spenders.country ASC, money_spent DESC

