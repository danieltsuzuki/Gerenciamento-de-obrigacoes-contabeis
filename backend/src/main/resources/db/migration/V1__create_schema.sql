CREATE TABLE company (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    cnpj       VARCHAR(14)  NOT NULL,
    active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_company_cnpj UNIQUE (cnpj)
);

CREATE TABLE users (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL,
    password   VARCHAR(255) NOT NULL,
    active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_email UNIQUE (email)
);

CREATE TABLE obligation (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id     BIGINT       NOT NULL,
    responsible_id BIGINT       NOT NULL,
    title          VARCHAR(255) NOT NULL,
    description    TEXT NULL,
    status         VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    due_date       DATE         NOT NULL,
    completed_at   DATETIME NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_obligation_company     FOREIGN KEY (company_id)     REFERENCES company (id),
    CONSTRAINT fk_obligation_responsible FOREIGN KEY (responsible_id) REFERENCES users (id),
    CONSTRAINT ck_obligation_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED'))
);
CREATE INDEX idx_obligation_company     ON obligation (company_id);
CREATE INDEX idx_obligation_responsible ON obligation (responsible_id);
CREATE INDEX idx_obligation_status_due  ON obligation (status, due_date);

CREATE TABLE attachment (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    obligation_id BIGINT       NOT NULL,
    file_name     VARCHAR(255) NOT NULL,
    file_path     VARCHAR(500) NOT NULL,
    content_type  VARCHAR(100) NOT NULL,
    file_size     BIGINT       NOT NULL,
    uploaded_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attachment_obligation FOREIGN KEY (obligation_id) REFERENCES obligation (id)
);
CREATE INDEX idx_attachment_obligation ON attachment (obligation_id);

