-- V3__add_audit_and_obligation_history.sql
-- SPEC-035: Implementar auditoria de operações e histórico de status

-- 1. Colunas de auditoria em company (created_by e updated_by referenciando users.id)
ALTER TABLE company
    ADD COLUMN created_by BIGINT NULL,
    ADD COLUMN updated_by BIGINT NULL,
    ADD CONSTRAINT fk_company_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    ADD CONSTRAINT fk_company_updated_by FOREIGN KEY (updated_by) REFERENCES users (id);

CREATE INDEX idx_company_created_by ON company (created_by);
CREATE INDEX idx_company_updated_by ON company (updated_by);

-- 2. Colunas de auditoria em users (created_by e updated_by referenciando users.id)
ALTER TABLE users
    ADD COLUMN created_by BIGINT NULL,
    ADD COLUMN updated_by BIGINT NULL,
    ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users (id);

CREATE INDEX idx_users_created_by ON users (created_by);
CREATE INDEX idx_users_updated_by ON users (updated_by);

-- 3. Colunas de auditoria em obligation (created_by e updated_by referenciando users.id)
ALTER TABLE obligation
    ADD COLUMN created_by BIGINT NULL,
    ADD COLUMN updated_by BIGINT NULL,
    ADD CONSTRAINT fk_obligation_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    ADD CONSTRAINT fk_obligation_updated_by FOREIGN KEY (updated_by) REFERENCES users (id);

CREATE INDEX idx_obligation_created_by ON obligation (created_by);
CREATE INDEX idx_obligation_updated_by ON obligation (updated_by);

-- 4. Coluna de auditoria em attachment (uploaded_by referenciando users.id)
ALTER TABLE attachment
    ADD COLUMN uploaded_by BIGINT NULL,
    ADD CONSTRAINT fk_attachment_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users (id);

CREATE INDEX idx_attachment_uploaded_by ON attachment (uploaded_by);

-- 5. Tabela de histórico imutável das transições de status da obrigação
CREATE TABLE obligation_status_history (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    obligation_id BIGINT      NOT NULL,
    from_status   VARCHAR(20) NULL,
    to_status     VARCHAR(20) NOT NULL,
    changed_by    BIGINT      NULL,
    changed_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_obligation FOREIGN KEY (obligation_id) REFERENCES obligation (id),
    CONSTRAINT fk_history_changed_by FOREIGN KEY (changed_by) REFERENCES users (id),
    CONSTRAINT ck_history_to_status CHECK (to_status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED')),
    CONSTRAINT ck_history_from_status CHECK (from_status IS NULL OR from_status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED'))
);

CREATE INDEX idx_history_obligation ON obligation_status_history (obligation_id);
CREATE INDEX idx_history_changed_at ON obligation_status_history (changed_at);

