-- =============================================================
-- Script: westeros.sql  (MySQL 8)
-- Banco de exemplo: casas e personagens de Game of Thrones
-- Modelagem de Banco de Dados - Prof. Cid Andrade
-- =============================================================

-- Passo 1 - Recomeçar do zero: DROP e CREATE DATABASE
DROP DATABASE IF EXISTS westeros;

CREATE DATABASE westeros
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- Passo 2 - Selecionar o banco: USE
USE westeros;

-- Passo 3 - DROP e CREATE TABLE casa
DROP TABLE IF EXISTS casa;

CREATE TABLE casa (
  id_casa  INT          NOT NULL AUTO_INCREMENT,
  nome     VARCHAR(50)  NOT NULL,
  lema     VARCHAR(100) NOT NULL,
  sede     VARCHAR(60)  NULL,

  CONSTRAINT pk_casa      PRIMARY KEY (id_casa),
  CONSTRAINT uq_casa_nome UNIQUE (nome),
  CONSTRAINT ck_casa_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0)
) ENGINE = InnoDB;

-- Passo 4 - DROP e CREATE TABLE personagem
DROP TABLE IF EXISTS personagem;

CREATE TABLE personagem (
  id_personagem INT              NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(80)      NOT NULL,
  titulo        VARCHAR(80)      NULL,
  idade         TINYINT UNSIGNED NULL,
  vivo          BOOLEAN          NOT NULL DEFAULT TRUE,
  id_casa       INT              NOT NULL,

  CONSTRAINT pk_personagem           PRIMARY KEY (id_personagem),
  CONSTRAINT uq_personagem_nome_casa UNIQUE (nome, id_casa),
  CONSTRAINT ck_personagem_idade     CHECK (idade BETWEEN 0 AND 120),
  CONSTRAINT fk_personagem_casa      FOREIGN KEY (id_casa)
      REFERENCES casa (id_casa)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Passo 5 - INSERT INTO: uma casa
INSERT INTO casa (nome, lema, sede)
VALUES ('Stark', 'O inverno está chegando', 'Winterfell');

-- Passo 6 - INSERT INTO: várias casas num só comando
INSERT INTO casa (nome, lema, sede) VALUES
  ('Lannister', 'Ouça-me rugir',    'Rochedo Casterly'),
  ('Targaryen', 'Fogo e Sangue',    'Pedra do Dragão'),
  ('Greyjoy',   'Nós não semeamos', 'Pyke');

-- Passo 7 - INSERT INTO: os personagens
INSERT INTO personagem (nome, titulo, idade, id_casa) VALUES
  ('Eddard Stark',       'Senhor de Winterfell', 35, 1),
  ('Sansa Stark',        NULL,                   13, 1),
  ('Arya Stark',         NULL,                   11, 1),
  ('Tyrion Lannister',   'Mão do Rei',           32, 2),
  ('Cersei Lannister',   'Rainha Regente',       34, 2),
  ('Daenerys Targaryen', 'Mãe dos Dragões',      16, 3),
  ('Theon Greyjoy',      'Príncipe de Pyke',     19, 4);

-- Passo 8 - SELECT com INNER JOIN
-- C01 - Listar cada personagem com o nome e a sede da sua casa
-- Atende: P1 - Saber a que casa cada personagem pertence e onde fica a sede
SELECT p.nome   AS personagem,
       p.titulo,
       c.nome   AS casa,
       c.sede
  FROM personagem AS p
 INNER JOIN casa  AS c
    ON c.id_casa = p.id_casa
 ORDER BY c.nome, p.nome;

-- Passo 9 - UPDATE: Eddard Stark morre
UPDATE personagem
   SET vivo = FALSE
 WHERE id_personagem = 1;

-- Passo 10 - UPDATE: Sansa vira Rainha do Norte
UPDATE personagem
   SET titulo = 'Rainha do Norte',
       idade  = idade + 7
 WHERE id_personagem = 2;

-- Passo 11 - DELETE barrado pela chave estrangeira
-- Demonstração: este comando FALHA com ERROR 1451 (a FK protege a casa).
-- DELETE FROM casa
--  WHERE nome = 'Greyjoy';

-- Passo 12 - DELETE: primeiro o personagem
DELETE FROM personagem
 WHERE id_personagem = 7;

-- Passo 13 - SELECT com LEFT JOIN e GROUP BY
-- C02 - Contar, por casa, os personagens cadastrados e os vivos
-- Atende: K1 - Personagens vivos por casa
SELECT c.nome                   AS casa,
       COUNT(p.id_personagem)   AS total,
       COALESCE(SUM(p.vivo), 0) AS vivos
  FROM casa AS c
  LEFT JOIN personagem AS p
    ON p.id_casa = c.id_casa
 GROUP BY c.id_casa, c.nome
 ORDER BY c.nome;

-- Passo 14 - DELETE: agora a casa sai
DELETE FROM casa
 WHERE nome = 'Greyjoy';
