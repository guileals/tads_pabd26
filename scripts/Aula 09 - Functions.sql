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