/*
    Aula 09 - FUNCTIONS
*/

CREATE OR REPLACE FUNCTION nome_funcao(
  parametro tipo
)
RETURNS tipo
LANGUAGE plpgsql
-- VOLATILE: significa que a função pode modificar o banco de dados ou depender de variáveis externas, e o PostgreSQL não pode otimizar chamadas subsequentes.
-- STABLE: significa que a função não modifica o banco de dados e retorna o mesmo resultado para os mesmos parâmetros dentro de uma única transação, permitindo otimizações.
-- IMMUTABLE: significa que a função não modifica o banco de dados e sempre retorna o mesmo resultado para os mesmos parâmetros, permitindo otimizações ainda mais agressivas.
-- Se não houver indicação, o padrão é VOLATILE.
AS $$
DECLARE
    variavel tipo;
BEGIN
    -- validações e comandos SQL
    RETURN variavel;
END;
$$;

-- Função que retorna o valor gasto por um determinado cliente 
drop function if exists get_customer_total_spent;
create or replace function get_customer_total_spent(
    p_customer_id int
)
returns numeric
language plpgsql
STABLE
as $$
declare
    v_total numeric;
begin
    if p_customer_id is null or p_customer_id <= 0 then
        raise exception 'customer_id inválido: %', p_customer_id;
    end if;

    if not exists (
        select 1 from customer where customer_id = p_customer_id
    ) then
        raise exception 'Cliente % não encontrado!', p_customer_id;
    end if;

    select coalesce(sum(amount), 0)
    into v_total
    from payment
    where customer_id = p_customer_id;

    return v_total;
end;
$$;

select get_customer_total_spent(1);
select get_customer_total_spent(-1);
select get_customer_total_spent(9999);

-- Função que retorna quantos filmes tem duração entre valores A e B?
drop function if exists get_film_count;
create or replace function get_film_count(
    p_len_from int,
    p_len_to int
)
returns int
language plpgsql
as
$$
declare
    v_film_count int;
begin
    if (p_len_from is null or 
        p_len_to is null or 
        p_len_from < 0 or 
        p_len_to < 0 or 
        p_len_from > p_len_to
    ) then
        raise exception 'Parâmetros inválidos: A = %, B = %', p_len_from, p_len_to;
    end if;

    select count(*) 
    into v_film_count
    from film 
    where length between p_len_from and p_len_to;

    return v_film_count;
end;
$$;

select get_film_count(90, 120);
select get_film_count(120, 90);
select get_film_count(-10, null);

-- Função que retorna quais filmes tem duração entre valores A e B?
drop function if exists get_films_by_length;
create or replace function get_films_by_length(
    p_len_from film.length%TYPE,
    p_len_to film.length%TYPE
)
returns
table(
    film_id film.film_id%TYPE,
    title film.title%TYPE,
    length film.length%TYPE
)
language plpgsql
as
$$
begin
    return query
    select f.film_id, f.title, f.length from film f
    where f.length between p_len_from and p_len_to
    order by f.length, f.title desc;
end;
$$;

select * from get_films_by_length(90::smallint, 120::smallint);

-- PROCEDURES
drop procedure if exists register_rental_with_payment;
create or replace procedure register_rental_with_payment(
    p_customer_id customer.customer_id%TYPE,
    p_inventory_id inventory.inventory_id%TYPE,
    p_staff_id staff.staff_id%TYPE,
    p_amount payment.amount%TYPE
)
language plpgsql
as $$
declare
    v_rental_id rental.rental_id%TYPE;
begin
    insert into rental(
        rental_date,
        inventory_id,
        customer_id,
        staff_id
    )
    values (
        now(),
        p_inventory_id,
        p_customer_id,
        p_staff_id
    )
    returning rental_id into v_rental_id;

    insert into payment (
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date
    )
    values (
        p_customer_id,
        p_staff_id,
        v_rental_id,
        p_amount,
        now()
    );

    raise notice 'Aluguel % registrado!', v_rental_id;
end;
$$;

begin;

call register_rental_with_payment(1::smallint, 1::smallint, 1::smallint, 5.99::numeric);

select * from rental where customer_id = 1
order by rental_id desc
limit 1;

rollback;

select * from rental where customer_id = 1
order by rental_id desc
limit 1;