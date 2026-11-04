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

-- Função que retorna quais filmes tem duração entre valores A e B?