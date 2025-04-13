- This file contains various SQL queries that can be used to interact with the bookstore database.

-- Query to retrieve all books by a specific author
SELECT b.title, a.name AS author_name
FROM book b
JOIN book_author ba ON b.id = ba.book_id
JOIN author a ON ba.author_id = a.id
WHERE a.name = 'Author Name';

-- Query to check all orders placed by a specific customer
SELECT co.id AS order_id, co.order_date, co.total_amount
FROM cust_order co
JOIN customer c ON co.customer_id = c.id
WHERE c.name = 'Customer Name';

-- Query to list all available shipping methods
SELECT sm.method_name, sm.cost
FROM shipping_method sm;

-- Query to get the order history of a specific order
SELECT oh.order_id, oh.status, oh.updated_at
FROM order_history oh
WHERE oh.order_id = 'Order ID';

-- Query to count the number of books in each language
SELECT bl.language_name, COUNT(b.id) AS book_count
FROM book b
JOIN book_language bl ON b.language_id = bl.id
GROUP BY bl.language_name;

-- Query to retrieve customer addresses with their status
SELECT ca.customer_id, a.street, a.city, a.zip_code, as.status_name
FROM customer_address ca
JOIN address a ON ca.address_id = a.id
JOIN address_status as ON ca.status_id = as.id;