drop table if exists funcionario cascade;
drop table if exists departmento cascade;

create table funcionario(
    cpf char(11) primary key,
    pnome varchar(50) not null,
    unome varchar(50) not null,
    email varchar(50) unique,
    adress varchar(100),
    wage numeric(7, 2),
    data_born date,
    sex char(1),
    cpf_supervisor char(11),
    department_number smallint,

    constraint funcionario_wage_check
    check (wage >= 2000 and wage <= 15000)
);

create table departmento(
    number smallint primary key,
    name varchar(50) unique,
    manager_cpf char(11) not null
);

-- Add a new atribute 
alter table departmento
add column init_date date;

-- Fix atribute to not null
alter table departmento
alter column init_date set not null;

-- Drop atribute
alter table departmento
drop column init_date;

-- Add a new Default constraint
alter table funcionario
alter column adress set default 'Macau-RN';

-- Drop a Default constraint
alter table funcionario
alter column adress drop default;

-- Add a new constraint CHECK
alter table funcionario
add constraint funcionario_sex_check
-- check (lower(sex) in ('m', 'f', 'o'));
check (sex in ('m', 'f', 'o', 'M', 'F', 'O'));

-- Drop a constraint CHECK
alter table funcionario
drop constraint if exists funcionario_sex_check;

-- Add a new constraint foreign key
alter table funcionario
add constraint funcionario_department_number_fk
foreign key (department_number)
references departmento(number)
-- no action, set null, cascade, set default
on delete no action
on update cascade;

-- Add a new table
create table project(
    code serial primary key,
    name varchar(50) not null,
    start_date date,
    value numeric(10,2) default 0
);

-- Add a new column
alter table project
add column manager_cpf char(11);

-- Rename a column
alter table project
rename column manager_cpf to manager_cpf_2;

-- Change a column type
alter table project
alter column value type numeric(12,2);

-- Add a default value
alter table project
alter column start_date set default current_date;

-- Drop a default value
alter table project
alter column start_date drop default;

-- Add a unique constraint
alter table project
add constraint project_name_unique unique (name);

-- Drop a unique constraint
alter table project
drop constraint if exists project_name_unique;

-- Drop a column
alter table project
drop column if exists manager_cpf_2;

-- Drop table
drop table if exists project cascade;
