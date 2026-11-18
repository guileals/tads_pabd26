# LISTA DE EXERCÍCIOS 1 — Sistema de E-commerce

## Visão geral

Este documento descreve o modelo relacional de um sistema de e-commerce composto pelas relações:

- `users`: usuários ou clientes cadastrados.
- `products`: produtos disponíveis para venda.
- `orders`: pedidos realizados pelos usuários.
- `orders_products`: itens que compõem cada pedido.

O relacionamento entre as tabelas é representado por chaves primárias e estrangeiras:

```text
users 1 ───────── N orders
orders 1 ──────── N orders_products
products 1 ────── N orders_products
```

## Definição e dados do sistema

```sql
DROP TABLE IF EXISTS orders_products CASCADE;
DROP TABLE IF EXISTS orders     CASCADE;
DROP TABLE IF EXISTS products   CASCADE;
DROP TABLE IF EXISTS users      CASCADE;

CREATE TABLE users (
    id serial PRIMARY KEY,
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
           CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'canceled')),
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
    ('Ana Souza',    'ana@tads.ifrn'),
    ('Bruno Lima',   'bruno@tads.ifrn'),
    ('Carla Alves',  'carla@tads.ifrn'),
    ('Diego Santos', 'diego@tads.ifrn'),
    ('Elisa Prado',  'elisa@tads.ifrn'),
    ('Felipe Silva', 'felipe@tads.ifrn');

INSERT INTO products (name, price, stock) VALUES
    ('Notebook Dell Inspiron',            4500.00, 10),
    ('Mouse Logitech MX',                 89.90, 50),
    ('Teclado Mecânico Logitech',         349.90, 30),
    ('Monitor 27" Dell',                  1899.00, 12),
    ('Webcam HD Logitech',                259.00, 40),
    ('Headset Gamer Logitech',            499.90, 25),
    ('Cadeira Ergonômica Flexform',       1299.00,  8),
    ('SSD 1TB Kingston',                  459.00, 20),
    ('Notebook Apple Macbook Pro M5',     19999.00, 8);

-- interval - second, minute, hour, day, month, year
INSERT INTO orders (user_id, order_date, status, total) VALUES
    (1, now() - interval '2 days',  'delivered', 4589.90),
    (2, now() - interval '5 days',  'shipped',    349.90),
    (3, now() - interval '10 days', 'paid',       618.90),
    (1, now() - interval '15 days', 'delivered', 1299.00),
    (4, now() - interval '20 days', 'paid',       459.00),
    (5, now() - interval '25 days', 'pending',    259.00),
    (2, now() - interval '40 days', 'delivered', 1899.00),
    (3, now() - interval '50 days', 'canceled',   499.90),
    (4, now() - interval '60 days', 'delivered',  349.90),
    (5, now() - interval '90 days', 'delivered', 4500.00);

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
```

## Prática DML/DQL

1. Liste os produtos com preço superior a R$ 1000.
2. Liste os produtos ordenados pelo preço, do maior para o menor.
3. Aumente o preço de todos os produtos da `Dell` em 10%.
4. Exclua todos os produtos que sejam do tipo `Macbook`.
5. Exclua um produto que não possua pedidos associados.
6. Liste todos os pedidos realizados nos últimos 30 dias.
7. Liste os pedidos e os respectivos nomes de usuário.
8. Liste todos os usuários e seus pedidos, inclusive usuários sem pedidos.
9. Liste todos os usuários (id, nome e email) que realizaram pelo menos um pedido.
10. Liste produtos que nunca foram vendidos.
11. Liste usuários que nunca realizaram pedidos.
12. Liste os produtos com preço acima da média em ordem decrescente.
13. Liste a quantidade de pedidos realizados por cada usuário.
14. Listar os três produtos mais vendidos.
15. Gerar um relatório com: usuários, quantidade de pedidos e valor total comprado.

---

## Resolução da lista

### 1) Produtos com preço superior a R$ 1000

```sql
SELECT *
FROM products
WHERE price > 1000
ORDER BY price DESC;
```

### 2) Produtos ordenados pelo preço, do maior para o menor

```sql
SELECT *
FROM products
ORDER BY price DESC;
```

### 3) Aumentar o preço dos produtos da Dell em 10%

```sql
UPDATE products
SET price = price * 1.10
WHERE name ILIKE '%Dell%';
```

### 4) Excluir os produtos do tipo Macbook

```sql
DELETE FROM products
WHERE name ILIKE '%Macbook%';
```

### 5) Excluir um produto que não tenha pedidos associados

```sql
DELETE FROM products
WHERE id = (
    SELECT p.id
    FROM products p
    LEFT JOIN orders_products op ON op.product_id = p.id
    WHERE op.id IS NULL
    LIMIT 1
);
```

### 6) Pedidos realizados nos últimos 30 dias

```sql
SELECT *
FROM orders
WHERE order_date >= now() - interval '30 days';
```

### 7) Pedidos com o nome do usuário

```sql
SELECT o.id,
       o.user_id,
       u.name AS nome_usuario,
       o.order_date,
       o.status,
       o.total
FROM orders o
JOIN users u ON u.id = o.user_id
ORDER BY o.order_date DESC;
```

### 8) Usuários e seus pedidos, incluindo usuários sem pedidos

```sql
SELECT u.id,
       u.name,
       u.email,
       o.id AS pedido_id,
       o.order_date,
       o.status,
       o.total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
ORDER BY u.id, o.id;
```

### 9) Usuários que realizaram pelo menos um pedido

```sql
SELECT DISTINCT u.id,
                u.name,
                u.email
FROM users u
JOIN orders o ON o.user_id = u.id
ORDER BY u.id;
```

### 10) Produtos que nunca foram vendidos

```sql
SELECT p.*
FROM products p
LEFT JOIN orders_products op ON op.product_id = p.id
WHERE op.id IS NULL
ORDER BY p.name;
```

### 11) Usuários que nunca realizaram pedidos

```sql
SELECT u.*
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL
ORDER BY u.name;
```

### 12) Produtos com preço acima da média, em ordem decrescente

```sql
SELECT *
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
```

### 13) Quantidade de pedidos por usuário

```sql
SELECT u.id,
       u.name,
       COUNT(o.id) AS quantidade_pedidos
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name
ORDER BY quantidade_pedidos DESC, u.name;
```

### 14) Três produtos mais vendidos

```sql
SELECT p.id,
       p.name,
       SUM(op.quantity) AS quantidade_vendida
FROM products p
JOIN orders_products op ON op.product_id = p.id
GROUP BY p.id, p.name
ORDER BY quantidade_vendida DESC, p.name
LIMIT 3;
```

### 15) Relatório com usuários, quantidade de pedidos e valor total comprado

```sql
SELECT u.id,
       u.name,
       COUNT(DISTINCT o.id) AS quantidade_pedidos,
       COALESCE(SUM(o.total), 0) AS valor_total_comprado
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name
ORDER BY valor_total_comprado DESC, quantidade_pedidos DESC;
```

---

