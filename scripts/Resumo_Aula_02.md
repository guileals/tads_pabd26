# Resumo das alterações realizadas

Eu ajustei o arquivo [scripts/Aula 02 - Review DDL.sql](scripts/Aula%2020-%20Review%20DDL.sql) para completar as restrições de chave estrangeira que faltavam na modelagem.

## O que foi feito

Eu adicionei duas chaves estrangeiras no mesmo padrão já usado no script:

- `funcionario.cpf_supervisor` referencia `funcionario.cpf`
- `departmento.manager_cpf` referencia `funcionario.cpf`

Também mantive a estrutura simples e didática da aula, usando `alter table ... add constraint ... foreign key ... references ...` e definindo regras de atualização e exclusão.

## Motivo da alteração

A ideia era garantir a integridade referencial entre as tabelas:

- um funcionário pode ter um supervisor que também é um funcionário;
- um departamento pode ter um gerente cadastrado como funcionário.

Isso evita que existam registros inconsistentes no banco.

## Arquivo alterado

- [scripts/Aula 02 - Review DDL.sql](scripts/Aula%2020-%20Review%20DDL.sql)
