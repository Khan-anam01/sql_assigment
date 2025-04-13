-- Create the BookStore database
CREATE DATABASE IF NOT EXISTS BookStore;
USE BookStore;

-- Drop tables if they exist to avoid conflicts when re-running the script
-- Tables must be dropped in reverse order due to foreign key constraints
DROP TABLE IF EXISTS order_history;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS cust_order;
DROP TABLE IF EXISTS customer_address;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS shipping_method;
DROP TABLE IF EXISTS order_status;
DROP TABLE IF EXISTS address_status;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS book_language;

-- Create lookup tables first (tables with no foreign key dependencies)

-- Book Language lookup table
CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Country lookup table
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Address Status lookup table
CREATE TABLE address_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Order Status lookup table
CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Shipping Method lookup table
CREATE TABLE shipping_method (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    cost DECIMAL(6,2) NOT NULL
) ENGINE=InnoDB;

-- Create main entity tables

-- Publisher table
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255)
) ENGINE=InnoDB;

-- Author table
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    biography TEXT,
    birth_date DATE,
    INDEX idx_author_name (last_name, first_name)
) ENGINE=InnoDB;

-- Book table
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    publication_date DATE,
    price DECIMAL(10,2) NOT NULL,
    publisher_id INT,
    language_id INT,
    page_count INT,
    description TEXT,
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (language_id) REFERENCES book_language(language_id) ON DELETE SET NULL,
    INDEX idx_book_title (title)
) ENGINE=InnoDB;

-- Customer table
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_customer_name (last_name, first_name),
    INDEX idx_customer_email (email)
) ENGINE=InnoDB;

-- Address table
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE RESTRICT,
    INDEX idx_address_postal (postal_code)
) ENGINE=InnoDB;

-- Create junction tables and tables with foreign key dependencies

-- Book-Author junction table
CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Customer-Address junction table
CREATE TABLE customer_address (
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    status_id INT NOT NULL,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES address_status(status_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Customer Order table
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    order_total DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(method_id) ON DELETE RESTRICT,
    FOREIGN KEY (shipping_address_id) REFERENCES address(address_id) ON DELETE RESTRICT,
    INDEX idx_order_date (order_date),
    INDEX idx_customer_order (customer_id)
) ENGINE=InnoDB;

-- Order Line table
CREATE TABLE order_line (
    line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE RESTRICT,
    INDEX idx_order_book (order_id, book_id),
    CHECK (quantity > 0)
) ENGINE=InnoDB;

-- Order History table
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status_id INT NOT NULL,
    status_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    comments TEXT,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES order_status(status_id) ON DELETE RESTRICT,
    INDEX idx_order_history (order_id, status_date)
) ENGINE=InnoDB;

-- Insert sample data into lookup tables

-- Book Languages
INSERT INTO book_language (language_name) VALUES
('English'),
('Spanish'),
('French'),
('German'),
('Chinese'),
('Japanese'),
('Arabic');

-- Countries
INSERT INTO country (country_name) VALUES
('United States'),
('United Kingdom'),
('Canada'),
('Australia'),
('Germany'),
('France'),
('Spain'),
('China'),
('Japan'),
('India');

-- Address Statuses
INSERT INTO address_status (status_name) VALUES
('Current'),
('Previous'),
('Shipping'),
('Billing'),
('Business');

-- Order Statuses
INSERT INTO order_status (status_name) VALUES
('Pending'),
('Processing'),
('Shipped'),
('Delivered'),
('Cancelled'),
('Returned'),
('On Hold');

-- Shipping Methods
INSERT INTO shipping_method (method_name, cost) VALUES
('Standard Shipping', 4.99),
('Express Shipping', 9.99),
('Overnight Shipping', 19.99),
('International Shipping', 14.99),
('Free Shipping', 0.00);

-- Create database users and assign privileges

-- Create admin user with full privileges
CREATE USER IF NOT EXISTS 'bookstore_admin'@'localhost' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON BookStore.* TO 'bookstore_admin'@'localhost';

-- Create manager user with limited privileges
CREATE USER IF NOT EXISTS 'bookstore_manager'@'localhost' IDENTIFIED BY 'manager_password';
GRANT SELECT, INSERT, UPDATE ON BookStore.* TO 'bookstore_manager'@'localhost';
REVOKE INSERT, UPDATE ON BookStore.customer FROM 'bookstore_manager'@'localhost';
REVOKE INSERT, UPDATE ON BookStore.address FROM 'bookstore_manager'@'localhost';

-- Create employee user with read-only access to most tables
CREATE USER IF NOT EXISTS 'bookstore_employee'@'localhost' IDENTIFIED BY 'employee_password';
GRANT SELECT ON BookStore.book TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.author TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.publisher TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.book_language TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.cust_order TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.order_line TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.order_status TO 'bookstore_employee'@'localhost';
GRANT SELECT ON BookStore.order_history TO 'bookstore_employee'@'localhost';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;
