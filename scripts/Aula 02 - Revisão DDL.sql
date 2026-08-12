drop table if exists funcionario cascade;
drop table if exists departamento cascade;

create table funcionario(
    cpf char(11) primary key,
    pnome varchar(50) not null,
    unome varchar(50) not null,
    email varchar(50) unique,
    endereco varchar(100),
    salario numeric(7,2),
    data_nasc date,
    sexo char(1),
    cpf_supervisor char(11),
    numero_departamento smallint,

    constraint funcionario_salario_check
    check (salario >= 2000 and salario <= 15000)
);

create table departamento(
    numero smallint primary key,
    nome varchar(50) unique,
    cpf_gerente char(11)
);

-- Adicionar um novo atributo
alter table departamento
add column data_ini date;

-- Alterar um atributo para NOT NULL
alter table departamento
alter column data_ini set not null;

-- Excluir um atributo
alter table departamento
drop column data_ini;

-- Adicionar um valor padrão DEFAULT
alter table funcionario
alter column endereco set default 'Macau-RN';

-- Excluir um valor padrão DEFAULT
alter table funcionario
alter column endereco drop default;

-- Adicionar restrição (constraint) CHECK
alter table funcionario
add constraint funcionario_sexo_check
-- check (lower(sexo) in ('m', 'f', 'o'));
check (sexo in ('m', 'f', 'o', 'M', 'F', 'O'));

-- Excluir restrição
alter table funcionario
drop constraint if exists funcionario_sexo_check;

-- Adicionar restrição FOREIGN KEY
alter table funcionario
add constraint funcionario_num_dep_fk
foreign key (numero_departamento)
references departamento(numero)
-- no action, set null, restrict, cascade, set default
on delete no action
on update cascade;

-- TO DO: adicionar restrições FK para cpf_supervisor e cpf_gerente