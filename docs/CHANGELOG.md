# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.
O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

## [Não lançado]

## [0.1.0] - 2026-11-07

### Adicionado
- Configuração de ambiente Docker e Docker Compose (`docker-compose.yml` e `Dockerfile`) para instância MySQL 8.0.
- Modelo de variáveis de ambiente `.env.example` com valores fictícios e parametrização segura sem credenciais hardcoded.
- Regra no `.gitignore` para proteção de arquivos de credenciais (`.env`, `.env.*`).
- Configuração de datasource no `application.yml` apontando para variáveis de ambiente (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`), com `spring.jpa.hibernate.ddl-auto: validate` e Flyway habilitado.
- Migration inicial Flyway `V1__create_schema.sql` contendo:
  - Tabelas `company`, `users`, `obligation` e `attachment` com chaves primárias `BIGINT AUTO_INCREMENT`.
  - Chaves estrangeiras com integridade estrita sem `ON DELETE CASCADE`.
  - Restrições `UNIQUE` em `company.cnpj` e `users.email`.
  - Índices para busca em `obligation(company_id)`, `obligation(responsible_id)`, `obligation(status, due_date)` e `attachment(obligation_id)`.
  - Restrição `CHECK` para status da obrigação (`PENDING`, `IN_PROGRESS`, `COMPLETED`).
  - Colunas `active` para suporte a soft delete em empresas e usuários.
  - Timestamps de auditoria (`created_at`, `updated_at`, `uploaded_at`).
- Testes de integração automatizados com Testcontainers (`DatabaseMigrationIntegrationTest`) cobrindo:
  1. Aplicação com sucesso da migration `V1` em banco limpo.
  2. Rejeição de CNPJ duplicado pela restrição de unicidade do banco.
  3. Rejeição de e-mail duplicado pela restrição de unicidade do banco.
  4. Bloqueio de exclusão física de empresa com obrigações vinculadas pela restrição de integridade referencial.
- Documentação inicial do projeto em `README.md`, `docs/modelo-de-dados.md` (com diagrama ER Mermaid), `docs/status-implementacao.md` e `docs/index.md`.

