DROP TABLE IF EXISTS orders_products CASCADE;
DROP TABLE IF EXISTS orders     CASCADE;
DROP TABLE IF EXISTS products   CASCADE;
DROP TABLE IF EXISTS users      CASCADE;

CREATE TABLE users (
    id serial PRIMARY KEY,
  -- id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    email text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE products (
    id serial PRIMARY KEY,
    name text NOT NULL,
    price numeric(10,2) NOT NULL CHECK (price >= 0),
    stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id serial PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(id),
    order_date timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'pending'
           CHECK (status IN ('pending','paid','shipped','delivered','canceled')),
    total numeric(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE orders_products (
    id serial PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id integer NOT NULL REFERENCES products(id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO users (name, email) VALUES
    ('Ana Souza',    'ana@example.com'),
    ('Bruno Lima',   'bruno@example.com'),
    ('Carla Alves',  'carla@example.com'),
    ('Diego Santos', 'diego@example.com'),
    ('Elisa Prado',  'elisa@example.com'),
    ('Felipe Silva', 'felipe@example.com');

INSERT INTO products (name, price, stock) VALUES
    ('Notebook Dell',     4500.00, 10),
    ('Mouse Logitech',       89.90, 50),
    ('Teclado Mecânico',    349.90, 30),
    ('Monitor 27"',        1899.00, 12),
    ('Webcam HD',           259.00, 40),
    ('Headset Gamer',       499.90, 25),
    ('Cadeira Ergonômica', 1299.00,  8),
    ('SSD 1TB',             459.00, 20),
    ('Macbook Pro M4',     9999.00, 4),
    ('Macbook Pro M5',     19999.00, 8);

-- interval - second, minute, hour, day, month, year
INSERT INTO orders (user_id, order_date, status, total) VALUES
    (1, now() - interval '2 days, 3 hours',  'delivered', 4589.90),
    (2, now() - interval '5 days, 10 hours',  'shipped',    349.90),
    (3, now() - interval '10 days, 5 hours', 'paid',       618.90),
    (1, now() - interval '15 days, 2 hours', 'delivered', 1299.00),
    (4, now() - interval '20 days, 8 hours', 'paid',       459.00),
    (5, now() - interval '25 days, 12 hours', 'pending',    259.00),
    (2, now() - interval '40 days, 6 hours', 'delivered', 1899.00),
    (3, now() - interval '50 days, 15 hours', 'canceled',   499.90),
    (4, now() - interval '60 days, 9 hours', 'delivered',  349.90),
    (5, now() - interval '90 days, 4 hours', 'delivered', 4500.00);

INSERT INTO orders_products (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 4500.00),
    (1, 2, 1,   89.90),
    (2, 3, 1,  349.90),
    (3, 5, 1,  259.00),
    (3, 3, 1,  349.90),
    (3, 2, 1,   89.90),
    (4, 7, 1, 1299.00),
    (5, 8, 1,  459.00),
    (6, 5, 1,  259.00),
    (7, 4, 1, 1899.00),
    (8, 6, 1,  499.90),
    (9, 3, 1,  349.90),
    (10, 1, 1, 4500.00);