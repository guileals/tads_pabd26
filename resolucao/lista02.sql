-- Resolução da Lista de Exercícios 2 — Views, Indexes e Triggers
-- Execute conectado ao banco dvdrental.

-- Questão 01 - View de Performance da Equipe

DROP VIEW IF EXISTS v_staff_performance;
CREATE VIEW v_staff_performance AS
SELECT
    st.staff_id,
    COALESCE(st.first_name, '') || ' ' || COALESCE(st.last_name, '') AS full_name,
    COALESCE(ci.city, 'Undefined city') AS city,
    COALESCE(co.country, 'Undefined country') AS country,
    COUNT(DISTINCT re.rental_id) AS total_rentals,
    COALESCE(SUM(pa.amount), 0.0) AS total_amount
FROM staff AS st
LEFT JOIN rental AS re ON st.staff_id = re.staff_id
LEFT JOIN payment AS pa ON re.rental_id = pa.rental_id
LEFT JOIN store AS sto ON st.store_id = sto.store_id
LEFT JOIN address AS ad ON sto.address_id = ad.address_id
LEFT JOIN city AS ci ON ad.city_id = ci.city_id
LEFT JOIN country AS co ON ci.country_id = co.country_id
GROUP BY
    st.staff_id,
    st.first_name,
    st.last_name,
    ci.city,
    co.country;

SELECT * FROM v_staff_performance;


-- Questão 02 - View Materializada de Receita por Categoria

DROP MATERIALIZED VIEW IF EXISTS mv_category_total_sales;

CREATE MATERIALIZED VIEW mv_category_total_sales AS
SELECT
    ca.name AS category_name,
    COALESCE(SUM(pa.amount), 0.0) AS total_sales
FROM category AS ca
LEFT JOIN film_category AS fc ON ca.category_id = fc.category_id
LEFT JOIN inventory AS inv ON fc.film_id = inv.film_id
LEFT JOIN rental AS re ON inv.inventory_id = re.inventory_id
LEFT JOIN payment AS pa ON re.rental_id = pa.rental_id
GROUP BY ca.name;

CREATE UNIQUE INDEX idx_mv_category_name
ON mv_category_total_sales (category_name);

SELECT * FROM mv_category_total_sales;

-- A atualização concorrente não bloqueia as consultas à view.
-- Execute fora de um bloco BEGIN/COMMIT.
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_category_total_sales;


-- Questão 03 - Otimizando Filmes Atrasados

CREATE INDEX IF NOT EXISTS idx_rental_return_date_is_null
ON rental (return_date)
WHERE return_date IS NULL;

EXPLAIN ANALYZE
SELECT * FROM rental
WHERE return_date IS NULL;


-- Questão 04 - Busca Inteligente de Sinopses

-- pg_trgm permite usar índice GIN em buscas com LIKE '%palavra%'.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_film_description_search
ON film USING GIN (description gin_trgm_ops);

EXPLAIN ANALYZE
SELECT * FROM film
WHERE description LIKE '%documentary%'
   OR description LIKE '%drama%';

-- Exemplo de busca por outra palavra ou parte de palavra:
SELECT * FROM film
WHERE description LIKE '%act%';


-- Questão 05 - Histórico do Cliente

-- customer_id vem primeiro porque é usado no filtro por igualdade.
CREATE INDEX IF NOT EXISTS idx_customer_payment_date
ON payment (customer_id, payment_date);

EXPLAIN ANALYZE
SELECT * FROM payment
WHERE customer_id = 599
ORDER BY payment_date DESC;


-- Questão 06 - Login Case-Insensitive

CREATE INDEX IF NOT EXISTS idx_customer_email
ON customer (LOWER(email));

EXPLAIN ANALYZE
SELECT * FROM customer
WHERE LOWER(email) = LOWER('MARY.SMITH@sakilacustomer.org');


-- Questão 07 - Validação de Datas

CREATE OR REPLACE FUNCTION fn_insert_update_rental_return_date()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF NEW.return_date IS NOT NULL
       AND NEW.return_date < NEW.rental_date THEN
        RAISE EXCEPTION 'return_date não pode ser anterior a rental_date';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_insert_update_rental_return_date ON rental;
CREATE TRIGGER trg_insert_update_rental_return_date
BEFORE INSERT OR UPDATE ON rental
FOR EACH ROW
EXECUTE FUNCTION fn_insert_update_rental_return_date();

-- Teste de sucesso: alteração temporária, desfeita com ROLLBACK.
BEGIN;
UPDATE rental
SET return_date = rental_date + INTERVAL '1 day'
WHERE rental_id = (SELECT MIN(rental_id) FROM rental);
SELECT rental_id, rental_date, return_date
FROM rental
WHERE rental_id = (SELECT MIN(rental_id) FROM rental);
ROLLBACK;

-- Teste de falha (execute separadamente para ver a exceção):
-- UPDATE rental
-- SET return_date = rental_date - INTERVAL '1 day'
-- WHERE rental_id = (SELECT MIN(rental_id) FROM rental);


-- Questão 08 - Auditoria de Preços

CREATE TABLE IF NOT EXISTS film_cost_audit (
    film_id INT,
    old_cost NUMERIC(5, 2),
    new_cost NUMERIC(5, 2),
    changed_at TIMESTAMP DEFAULT now()
);

CREATE OR REPLACE FUNCTION fn_audit_film_cost()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO film_cost_audit (film_id, old_cost, new_cost)
    VALUES (OLD.film_id, OLD.replacement_cost, NEW.replacement_cost);

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_audit_film_cost ON film;
CREATE TRIGGER trg_audit_film_cost
AFTER UPDATE ON film
FOR EACH ROW
WHEN (NEW.replacement_cost <> OLD.replacement_cost)
EXECUTE FUNCTION fn_audit_film_cost();

-- Teste temporário: confira a auditoria antes do ROLLBACK.
BEGIN;
UPDATE film
SET replacement_cost = replacement_cost + 1.00
WHERE film_id = (SELECT MIN(film_id) FROM film);
SELECT * FROM film_cost_audit
WHERE film_id = (SELECT MIN(film_id) FROM film);
ROLLBACK;


-- Questão 09 - Proteção de Catálogo

CREATE OR REPLACE FUNCTION fn_prevent_delete_in_use_language()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM film AS f
        WHERE f.language_id = OLD.language_id
           OR f.original_language_id = OLD.language_id
    ) THEN
        RAISE EXCEPTION 'O idioma não pode ser excluído porque está associado a filmes.';
    END IF;

    RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_delete_in_use_language ON language;
CREATE TRIGGER trg_prevent_delete_in_use_language
BEFORE DELETE ON language
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_delete_in_use_language();

-- Teste de falha (execute separadamente; o idioma 1 costuma estar em uso):
-- DELETE FROM language WHERE language_id = 1;


-- Questão 10 - Sincronização de Estatísticas

CREATE TABLE IF NOT EXISTS customer_rental_stats (
    customer_id INT PRIMARY KEY,
    total_rentals INT DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
        ON DELETE CASCADE
);

DELETE FROM customer_rental_stats;

INSERT INTO customer_rental_stats (customer_id, total_rentals)
SELECT c.customer_id, COUNT(r.rental_id)
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

CREATE OR REPLACE FUNCTION fn_update_customer_rental_stats()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM customer_rental_stats
        WHERE customer_id = NEW.customer_id
    ) THEN
        INSERT INTO customer_rental_stats (customer_id, total_rentals)
        VALUES (NEW.customer_id, 1);
    ELSE
        UPDATE customer_rental_stats
        SET total_rentals = total_rentals + 1
        WHERE customer_id = NEW.customer_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_customer_rental_stats ON rental;
CREATE TRIGGER trg_update_customer_rental_stats
AFTER INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION fn_update_customer_rental_stats();

-- Teste temporário: confira o total atualizado antes do ROLLBACK.
BEGIN;
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (now(), 1, 1, 1);
SELECT * FROM customer_rental_stats
WHERE customer_id = 1;
ROLLBACK;