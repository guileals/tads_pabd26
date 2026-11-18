-- Resolução do Desafio de Programação 02 — Transações e concorrência
-- Execute conectado ao banco dvdrental.
-- A tabela customer relaciona o cliente a um endereço existente por address_id.

-- ============================================================
-- QUESTÃO 01 - Cadastro de cliente e perfil
-- ============================================================

BEGIN;

-- Cadastro válido: address_id 1 é um endereço já existente no dvdrental.
INSERT INTO customer (store_id, first_name, last_name, email, address_id)
VALUES (1, 'Cliente', 'Desafio 02', 'cliente.desafio02@example.com', 1);

-- ERRO intencional: first_name é obrigatório (NOT NULL).
-- No PostgreSQL, esse erro deixa a transação em estado abortado.
-- Se sua ferramenta parar a execução ao encontrar o erro, rode o ROLLBACK
-- manualmente na mesma sessão antes de continuar.
INSERT INTO customer (store_id, first_name, last_name, email, address_id)
VALUES (1, NULL, 'Cadastro Inválido', 'invalido.desafio02@example.com', 1);

-- Desfaz também o primeiro INSERT válido, pois a transação inteira falhou.
ROLLBACK;

-- Resultado esperado: nenhuma linha. O cliente do primeiro INSERT não existe,
-- pois o ROLLBACK desfaz todas as alterações ainda não confirmadas.
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE email = 'cliente.desafio02@example.com';

-- Atomicidade: evita que o cadastro fique parcialmente gravado (por exemplo,
-- cliente sem algum dado obrigatório ou sem os registros relacionados).


-- ============================================================
-- QUESTÃO 02 - Gestão de estoque com SAVEPOINT
-- ============================================================

BEGIN;

-- Primeira unidade válida. Guarde o inventory_id retornado para a questão 3.
INSERT INTO inventory (film_id, store_id)
VALUES (1, 1)
RETURNING inventory_id;

SAVEPOINT estoque_atualizado;

-- ERRO intencional: film_id 999999 não existe e viola a chave estrangeira.
-- Se a ferramenta parar neste erro, rode o ROLLBACK TO manualmente na mesma
-- sessão para recuperar a transação e então execute o INSERT válido e COMMIT.
INSERT INTO inventory (film_id, store_id)
VALUES (999999, 1);

-- Recupera a transação após o erro e mantém o INSERT anterior ao savepoint.
ROLLBACK TO SAVEPOINT estoque_atualizado;

-- Segunda unidade válida; este inventory_id também pode ser usado na questão 3.
INSERT INTO inventory (film_id, store_id)
VALUES (2, 1)
RETURNING inventory_id;

-- Os dois INSERTs válidos são confirmados; o INSERT inválido não é gravado.
COMMIT;

-- Os inventory_id devolvidos pelos dois INSERTs identificam exatamente as
-- unidades criadas; use-os aqui para conferir após o COMMIT:
-- SELECT inventory_id, film_id, store_id
-- FROM inventory
-- WHERE inventory_id IN (ID_RETORNADO_1, ID_RETORNADO_2);

-- Depois do COMMIT ficam ambos os registros válidos (o anterior e o posterior
-- ao savepoint), mas não o registro inválido. O savepoint permite recuperar
-- apenas a parte posterior a ele, sem cancelar todo o trabalho da transação.


-- ============================================================
-- QUESTÃO 03 - Concorrência sobre a mesma unidade de estoque
-- ============================================================

-- Pré-requisitos: execute a questão 2 e anote os inventory_id retornados.
-- Use o mesmo ID nas duas sessões de cada cenário, mas um ID diferente para
-- cada cenário (o cenário A termina excluindo sua unidade). Substitua :id pelo
-- número literal antes de executar cada comando; :id é apenas um marcador.
-- Escolha unidades sem locações associadas para que a FK de rental não
-- impeça o DELETE. Abra duas conexões SQL, ambas no isolamento padrão
-- READ COMMITTED. No dvdrental padrão, store_id = 2 é a outra loja.
-- Execute os passos manualmente e na ordem indicada; não rode este bloco como
-- um único script, pois as sessões precisam agir enquanto a outra aguarda.
-- BEGIN não reserva prioridade: prevalece quem obtiver primeiro o bloqueio da
-- linha com FOR UPDATE, UPDATE ou DELETE.

-- ------------------------------------------------------------
-- CENÁRIO A: A transfere primeiro; B aguarda e depois exclui
-- ------------------------------------------------------------
-- 1) Sessão A: bloqueie a unidade e mantenha a transação aberta.
-- BEGIN;
-- SELECT inventory_id, store_id
-- FROM inventory
-- WHERE inventory_id = :id
-- FOR UPDATE;
--
-- 2) Sessão B: tente excluir. Este comando ficará aguardando o bloqueio de A.
-- BEGIN;
-- DELETE FROM inventory WHERE inventory_id = :id;
--
-- 3) Enquanto B aguarda, sessão A transfere a unidade e confirma.
-- UPDATE inventory SET store_id = 2 WHERE inventory_id = :id;
-- COMMIT;
--
-- 4) O DELETE de B prossegue após o COMMIT de A e remove a unidade.
-- COMMIT;
-- Resultado: o UPDATE de A ocorre primeiro, mas a exclusão de B é a operação
-- final; a linha não existe mais. O bloqueio serializa as operações, não decide
-- qual regra de negócio deve prevalecer. Para preservar a transferência, B
-- precisa revalidar a autorização/estado antes de excluir.

-- ------------------------------------------------------------
-- CENÁRIO B: B exclui primeiro; A aguarda e depois não encontra a linha
-- ------------------------------------------------------------
-- 1) Sessão B: bloqueie e exclua a unidade, mas não confirme ainda.
-- BEGIN;
-- SELECT inventory_id, store_id
-- FROM inventory
-- WHERE inventory_id = :id
-- FOR UPDATE;
-- DELETE FROM inventory WHERE inventory_id = :id;
--
-- 2) Sessão A: tente transferir enquanto B mantém a transação aberta;
-- o UPDATE ficará aguardando.
-- BEGIN;
-- UPDATE inventory SET store_id = 2 WHERE inventory_id = :id;
--
-- 3) Sessão B confirma a exclusão.
-- COMMIT;
--
-- 4) Em READ COMMITTED, o UPDATE de A termina afetando zero linhas porque B
-- excluiu o registro. Verifique na sessão A e finalize sua transação:
-- SELECT inventory_id, store_id
-- FROM inventory
-- WHERE inventory_id = :id;
-- COMMIT;
-- Resultado: a unidade foi excluída e não pode ser transferida.
