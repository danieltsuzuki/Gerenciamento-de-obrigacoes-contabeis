-- Alinha o esquema da V1 aos nomes do domínio.
-- A V1 não é editada porque já pode ter sido aplicada.

ALTER TABLE company
    CHANGE COLUMN name legal_name VARCHAR(255) NOT NULL;

ALTER TABLE company
        ADD COLUMN trade_name VARCHAR(255) NULL;
