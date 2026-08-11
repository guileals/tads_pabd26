-- PostgreSQL basics playground
-- Use this file to practice the most common CRUD operations locally.

DROP TABLE IF EXISTS alunos;

CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    curso TEXT NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO alunos (nome, curso)
VALUES
    ('Ana', 'Banco de Dados'),
    ('Bruno', 'Engenharia de Software'),
    ('Carla', 'Sistemas Operacionais');

SELECT *
FROM alunos
ORDER BY id;

UPDATE alunos
SET curso = 'PostgreSQL'
WHERE nome = 'Ana';

DELETE FROM alunos
WHERE nome = 'Bruno';

BEGIN;

INSERT INTO alunos (nome, curso)
VALUES ('Diego', 'Transações');

ROLLBACK;

SELECT COUNT(*) AS total_de_alunos
FROM alunos;