
-- Tabel pelanggan
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

-- Tabel produk
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    price NUMERIC(10, 2),
    stock INT
);

-- Tabel transaksi langsung
CREATE TABLE transaction_items (
    item_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    transaction_date DATE
);

-- Data customers
INSERT INTO customers (name, email, city) VALUES
('Rina', 'rina@example.com', 'Jakarta'),
('Andi', 'andi@example.com', 'Bandung'),
('Sari', 'sari@example.com', 'Surabaya'),
('Budi', 'budi@example.com', 'Medan'),
('Lina', 'lina@example.com', 'Yogyakarta'),
('Dika', 'dika@example.com', 'Bekasi'),
('Eka', 'eka@example.com', 'Depok'),
('Yudi', 'yudi@example.com', 'Semarang'),
('Nina', 'nina@example.com', 'Bogor'),
('Tono', 'tono@example.com', 'Makassar');

-- Data products
INSERT INTO products (product_name, price, stock) VALUES
('Sabun Mandi', 5000, 100),
('Shampoo', 12000, 80),
('Pasta Gigi', 8000, 90),
('Sikat Gigi', 7000, 85),
('Minyak Goreng 1L', 15000, 70),
('Beras 5kg', 60000, 60),
('Gula Pasir 1kg', 13000, 75),
('Kopi Instan', 10000, 50),
('Teh Celup', 9000, 65),
('Mie Instan', 3000, 200);

-- Data transaction_items
INSERT INTO transaction_items (customer_id, product_id, quantity, transaction_date) VALUES
(1, 1, 2, '2025-05-01'),
(1, 2, 1, '2025-05-01'),
(2, 3, 1, '2025-05-01'),
(2, 5, 2, '2025-05-01'),
(3, 6, 1, '2025-05-02'),
(3, 4, 1, '2025-05-02'),
(4, 2, 1, '2025-05-02'),
(4, 7, 1, '2025-05-02'),
(5, 5, 1, '2025-05-03'),
(5, 1, 2, '2025-05-03'),
(6, 3, 3, '2025-05-03'),
(6, 10, 5, '2025-05-03'),
(7, 2, 2, '2025-05-03'),
(7, 4, 1, '2025-05-03'),
(8, 6, 1, '2025-05-04'),
(8, 9, 2, '2025-05-04'),
(9, 3, 1, '2025-05-04'),
(9, 2, 1, '2025-05-04'),
(10, 8, 1, '2025-05-04'),
(10, 10, 3, '2025-05-04'),
(1, 7, 1, '2025-05-05'),
(1, 1, 1, '2025-05-05'),
(2, 5, 2, '2025-05-05'),
(2, 3, 1, '2025-05-05'),
(3, 4, 1, '2025-05-06'),
(3, 9, 2, '2025-05-06'),
(4, 6, 1, '2025-05-06'),
(4, 8, 1, '2025-05-06'),
(5, 10, 4, '2025-05-06'),
(5, 2, 2, '2025-05-06'),
(3, 1, 1, '2025-05-02'),
(5, 4, 1, '2025-05-03'),
(6, 9, 2, '2025-05-03'),
(9, 1, 1, '2025-05-04'),
(10, 3, 1, '2025-05-04'),
(3, 10, 2, '2025-05-06'),
(4, 7, 1, '2025-05-06'),
(5, 6, 1, '2025-05-06'),
(8, 3, 2, '2025-05-04'),
(8, 5, 1, '2025-05-04');
