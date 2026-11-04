# DESAFIO DE PROGRAMAÇÃO 02

## Questão 1: Cadastro de Cliente e Perfil

**Cenário:** Um novo cliente deseja se cadastrar no sistema. Para isso, ele precisa inserir seus dados básicos e um endereço de contato.

**Tarefas:**

1. Inicie uma transação para inserir um novo registro na tabela `customer`.
2. Tente inserir um dado obrigatório que viole uma regra.
3. Observe a falha do comando.
4. Execute ROLLBACK.

O cliente cadastrado no passo 1 ainda existe na tabela? Por que o banco de dados deve "esquecer" todo o processo se um detalhe do cadastro falhar?

---

## Questão 2: Gestão de Estoque e Suprimentos

**Cenário:** O gestor do estoque quer registrar a chegada de novos filmes e atualizar o status de disponibilidade.

**Tarefas:**

1. Inicie uma transação para inserir um novo registro na tabela `inventory`.
2. Execute um SAVEPOINT chamado _estoque_atualizado_.
3. Tente inserir uma entrada de inventário para um filme que não existe.
4. O comando falhará, mas você deve manter a inserção anterior.
5. Insira um registro de inventário válido e finalize com COMMIT.

Após o COMMIT, a tabela possui apenas o registro válido ou ambos? Qual é a vantagem de usar SAVEPOINT aqui em vez de desistir de todo o processo de atualização do estoque?

---

## Questão 3: Concorrência na Gestão de Estoque e Suprimentos

**Cenário:** Na operação logística da locadora, dois gestores de suprimentos estão tentando processar o mesmo item físico de estoque (mesmo `inventory_id`) exatamente ao mesmo tempo. Um gestor está tentando transferir a unidade recém cadastrada para a outra loja para suprir uma demanda, enquanto o outro está tentando excluí-la pois afirma ter que devolver ao distribuidor devido a um erro na emissão da nota fiscal de aquisição.

Simule transações concorrentes em sessões diferentes para mostrar as ações de cada gestor. Considere que iniciar uma transação primeiro, por si só, não garante prioridade: a ordem depende de qual sessão obtém primeiro o bloqueio da linha. Mostre um passo a passo para os dois casos: sessão A obtendo o bloqueio primeiro e sessão B obtendo o bloqueio primeiro.

---

## Resolução

[Acessar o arquivo SQL com a resolução](../resolucao/desafio02.sql)
