# LISTA DE EXERCÍCIOS 2 - Views, Indexes e Triggers

## Orientações gerais

A base `dvdrental` representa uma locadora e contém 15 tabelas, incluindo `film`, `inventory`, `rental`, `payment`, `customer`, `staff`, `store`, `category` e tabelas associativas.

Lembre-se de validar todas as questões, realizando as devidas consultas.

---

## Questão 01 - View de Performance da Equipe

A gerência quer um painel rápido para avaliar o desempenho dos funcionários. Crie uma view chamada `v_staff_performance` que exiba:

- `staff_id` e o nome completo do funcionário;
- endereço (cidade + país) onde a loja dele está localizada;
- A quantidade total de locações (`rentals`) processadas por ele;
- O valor total arrecadado através dos pagamentos que ele registrou.

_Dica_: Use LEFT JOIN para não excluir funcionários recém-contratados que ainda não processaram locações, e COALESCE para tratar nulos como zero.

---

## Questão 02 - View Materializada de Receita por Categoria

O relatório de receita por categoria de filme é muito pesado, pois exige cruzar `category`, `film_category`, `inventory`, `rental` e `payment`. Crie uma Materialized View chamada `mv_category_total_sales` que liste o nome da categoria e o total de receita gerado por ela. Crie um índice único na MV que permita que ela seja atualizada de forma não-bloqueante (CONCURRENTLY). Escreva o comando SQL para recarregar os dados da MV sem bloquear as consultas dos usuários do sistema.

---

## Questão 03 - Otimizando Filmes Atrasados

O sistema de cobrança roda a cada hora buscando locações que ainda não foram devolvidas (`return_date IS NULL`) para calcular multas. Como a tabela `rental` é grande e a maioria dos filmes já foi devolvida, um _Seq Scan_ é muito caro. Crie um índice (parcial?) na tabela `rental` que indexe apenas as locações em aberto. Em seguida, escreva a consulta e use o `EXPLAIN ANALYZE` para provar que o índice está sendo utilizado.

---

## Questão 04 - Busca Inteligente de Sinopses

Os clientes reclamam que a busca por palavras-chave na descrição dos filmes (`description`) usando `LIKE '%palavra%'` está lenta e não encontra variações da palavra (ex: "act", "acting", "actor"). Crie um índice adequado para melhorar o desempenho na busca. Em seguida, escreva uma consulta par buscar _documentary_ e _drama_ na descrição. Use o `EXPLAIN ANALYZE` para provar que o índice está sendo utilizado.

---

## Questão 05 - Histórico do Cliente

Sempre que o cliente abre seu perfil no aplicativo, o sistema busca o histórico de pagamentos dele, ordenados do mais recente para o mais antigo:

`SELECT * FROM payment WHERE customer_id = X ORDER BY payment_date DESC`.

Para otimizar essa consulta específica, crie um índice multicoluna na tabela `payment`. Qual coluna deve vir primeiro no índice e por quê?

---

## Questão 06 - Login Case-Insensitive

O suporte técnico frequentemente busca clientes pelo e-mail, mas os atendentes não se preocupam com letras maiúsculas ou minúsculas (ex: buscam por `MARY.SMITH@...` quando o e-mail está gravado como `mary.smith@...`). Crie um **Índice Funcional** (Expression Index) na tabela `customer` que permita buscas rápidas e _case-insensitive_ na coluna `email`. Crie uma consulta usando `EXPLAIN ANALYZE` para provar que o índice está sendo utilizado.

---

## Questão 07 - Validação de Datas

Ocorreu um bug no front-end que permitiu inserir locações onde a data de devolução (`return_date`) era _anterior_ à data de locação (`rental_date`), gerando multas negativas. Crie um trigger `BEFORE INSERT OR UPDATE` na tabela `rental` que lance uma exceção (`RAISE EXCEPTION`) caso o `NEW.return_date` seja menor que o `NEW.rental_date`. Lembre-se de tratar o caso onde o `return_date` é `NULL` (o filme ainda está com o cliente). Realize 2 consultas teste para validar (sucesso/falha);

---

## Questão 08 - Auditoria de Preços

A administração suspeita que gerentes de loja estão alterando o custo de substituição (`replacement_cost`) de filmes raros sem autorização. Crie uma tabela de auditoria chamada `film_cost_audit` (`film_id`, `old_cost`, `new_cost`, `changed_at`) e uma trigger `AFTER UPDATE` na tabela `film` que insira um registro nessa tabela **apenas** se o `replacement_cost` for efetivamente modificado (utilize a cláusula `WHEN` na criação da trigger).

---

## Questão 09 - Proteção de Catálogo

Para evitar "buracos" no catálogo e erros de chave estrangeira órfã, o banco de dados não deve permitir a exclusão de um idioma da tabela `language` caso existam filmes cadastrados que o utilizem (seja como idioma original ou de áudio). Crie uma trigger `BEFORE DELETE` na tabela `language` que verifique as tabelas `film` (`language_id` e `original_language_id`). Se houver filmes vinculados, a exclusão deve ser abortada com uma mensagem de erro amigável.

---

## Questão 10 - Sincronização de Estatísticas

Para evitar contar as linhas da tabela `rental` toda vez que quisermos saber quantos filmes um cliente já alugou, vamos manter uma tabela de estatísticas.

- Crie a tabela `customer_rental_stats` (`customer_id` PK, `total_rentals` INT DEFAULT 0).
- Popule-a inicialmente com os dados atuais.
- Crie uma trigger `AFTER INSERT` na tabela `rental` que, a cada nova locação, atualize (incremento `+1`) o contador do respectivo cliente na tabela de estatísticas (verifique a existência).

---

## Resolução

[Acessar o arquivo SQL com a resolução](../resolucao/lista02.sql)
