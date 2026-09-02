-- VIEWS

-- No psql: \dv - visualizar as views existentes
-- No psql: \d+ v_users_orders - visualizar detalhes da view

-- 1. Resumo de pedidos por usuário (id, usuario, qtd_pedidos, total_gasto)
drop view if exists v_users_orders;
create view v_users_orders as
select 
    u.id id,
    u.name usuario,
    count(o.id) qtd_pedidos,
    coalesce(sum(o.total), 0) total_gasto
from users u
left join orders o on o.user_id = u.id
group by u.id, u.name;

-- select * from v_users_orders order by id;

-- 2. Relatório de vendas de produtos (id, produto, qtd_vendida, total_vendido)
drop view if exists v_products_sales;
create view v_products_sales as
select 
    p.id id,
    p.name produto,
    sum(op.quantity) qtd_vendida,
    sum(op.quantity * op.unit_price) total_vendido
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- select * from v_products_sales order by id;

-- 3. Relatório detalhado de pedidos
drop view if exists v_orders_details;
create view v_orders_details as
select
    o.id id,
    u.name usuario,
    u.email email,
    o.order_date,
    o.status,
    p.name produto,
    op.quantity qtd,
    op.unit_price valor_unitario,
    op.unit_price * op.quantity valor_total
from orders o
join users u on u.id = o.user_id
join orders_products op on op.order_id = o.id
join products p on p.id = op.product_id;

-- select * from v_orders_details order by id;

-- 4. Relatório de itens em estoque
drop view if exists v_products_in_stock;
create view v_products_in_stock as
select
    id,
    name produto,
    price valor,
    stock estoque
from products
where stock > 0
WITH CHECK OPTION;

-- select * from v_products_in_stock;

-- update products
-- set stock = 10
-- where id = 1;

-- update v_products_in_stock
-- set estoque = 0
-- where id = 1
-- returning id, produto, estoque;

-- insert into v_products_in_stock (produto, valor, estoque)
-- values ('Produto qualquer', 99, 0);

/*
MATERIALIZED VIEWS
*/

-- 5. Relatório de produtos mais vendidos
drop view if exists v_top_products;
create view v_top_products as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- explain analyze select * from v_top_products order by total_vendido desc limit 3;

drop view if exists mv_top_products;
create materialized view mv_top_products as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name
with data; -- padrão
-- with NO data; -- sem dados

-- explain analyze select * from mv_top_products order by total_vendido desc limit 3;

/*

QUERY PLAN                                                               
    
--------------------------------------------------------------------------------------------------------------------------------------------
----
 Limit  (cost=131.82..131.83 rows=3 width=76) (actual time=0.102..0.105 rows=3 loops=1)
   ->  Sort  (cost=131.82..134.02 rows=880 width=76) (actual time=0.101..0.103 rows=3 loops=1)
         Sort Key: (sum(((op.quantity)::numeric * op.unit_price))) DESC
         Sort Method: top-N heapsort  Memory: 25kB
         ->  HashAggregate  (cost=109.44..120.44 rows=880 width=76) (actual time=0.080..0.086 rows=7 loops=1)
               Group Key: p.id
               Batches: 1  Memory Usage: 49kB
               ->  Hash Join  (cost=61.75..92.52 rows=1354 width=56) (actual time=0.049..0.059 rows=12 loops=1)
                     Hash Cond: (op.product_id = p.id)
                     ->  Hash Join  (cost=31.95..59.14 rows=1354 width=24) (actual time=0.026..0.032 rows=12 loops=1)
                           Hash Cond: (op.order_id = o.id)
                           ->  Seq Scan on orders_products op  (cost=0.00..23.60 rows=1360 width=28) (actual time=0.004..0.006 rows=13 loops=1)
                           ->  Hash  (cost=21.00..21.00 rows=876 width=4) (actual time=0.008..0.009 rows=9 loops=1)
                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                 ->  Seq Scan on orders o  (cost=0.00..21.00 rows=876 width=4) (actual time=0.005..0.007 rows=9 loops=1)
                                       Filter: (status <> 'canceled'::text)
                                       Rows Removed by Filter: 1
                     ->  Hash  (cost=18.80..18.80 rows=880 width=36) (actual time=0.015..0.015 rows=9 loops=1)
                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                           ->  Seq Scan on products p  (cost=0.00..18.80 rows=880 width=36) (actual time=0.009..0.010 rows=9 loops=1)
 Planning Time: 0.272 ms
 Execution Time: 0.156 ms

QUERY PLAN                                                        
-------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=27.88..27.89 rows=3 width=76) (actual time=0.021..0.022 rows=3 loops=1)
   ->  Sort  (cost=27.88..29.83 rows=780 width=76) (actual time=0.020..0.020 rows=3 loops=1)
         Sort Key: total_vendido DESC
         Sort Method: top-N heapsort  Memory: 25kB
         ->  Seq Scan on mv_top_products  (cost=0.00..17.80 rows=780 width=76) (actual time=0.011..0.012 rows=7 loops=1)
 Planning Time: 0.063 ms
 Execution Time: 0.035 ms

*/

-- 6. MV para mostrar o total vendido por mês
drop materialized view if exists mv_monthly_sales;
create materialized view mv_monthly_sales as
select
    to_char(date_trunc('month', o.order_date), 'YYYY-MM') mes,
    sum(o.total) total_vendido
from orders o
where o.status <> 'canceled'
group by mes
with no data;

-- select * from mv_monthly_sales order by mes desc;

-- Recarregando a MV (bloqueada durante o refresh...)
refresh materialized view mv_monthly_sales;

create unique index idx_mv_monthly_sales_month
on mv_monthly_sales(mes);

-- CONCURENTLY: permite consultas na MV durante o REFRESH
refresh materialized view concurrently mv_monthly_sales;