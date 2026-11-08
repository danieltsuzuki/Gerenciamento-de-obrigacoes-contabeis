# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.
O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

## [Não lançado]

### Adicionado
- Endpoints REST para gerenciamento de empresas em `/api/companies`:
  - `POST /api/companies`: cadastro com validação de razão social, nome fantasia e CNPJ único.
  - `GET /api/companies`: listagem com paginação padrão Spring Data (`page`, `size`, `sort`) e filtro opcional por `active`.
  - `GET /api/companies/{id}`: busca de empresa por identificador numérico.
  - `PUT /api/companies/{id}`: atualização cadastral e inativação/ativação (`active`).
- Validador puro Java `Cnpj` com normalização (apenas dígitos), descarte de sequências repetidas e cálculo estrito dos dois dígitos verificadores (DVs).
- Anotação de Bean Validation `@ValidCnpj` e validador `CnpjValidator` para validação declarativa nos DTOs.
- DTOs de request e response: `CreateCompanyRequest`, `UpdateCompanyRequest` e `CompanyResponse`.
- Camada de mapeamento `CompanyMapper` e camada de serviço `CompanyService`.
- Tratamento global de exceções via `@RestControllerAdvice` (`GlobalExceptionHandler`) com respostas padronizadas para erros de validação (400), recurso não encontrado (404) e duplicidade de CNPJ (409).
- Documentação formal dos endpoints em `docs/api.md`.
- Suíte completa de testes automatizados: unitários de validador (`CnpjTest`), serviço (`CompanyServiceTest`), web layer (`CompanyControllerTest`) e integração com Testcontainers MySQL 8 (`CompanyApiIntegrationTest`).
- Entidades JPA `Company`, `Responsible`, `Obligation` e `Attachment`, com normalização defensiva, auditoria e relações LAZY.
- Enum de ciclo de vida de obrigações, transições protegidas e repositories sem operações `delete*`.
- Migration V2 para `legal_name` e `trade_name`.
- Testes unitários do domínio e integração MySQL 8 via Testcontainers.
- ADR sobre repositories sem operações de exclusão.

### Alterado
- A documentação passou a refletir `Responsible`, `legalName`, `tradeName` e `storageKey`.
- A autenticação permanece fora do escopo; `passwordHash` apenas mapeia `users.password`.
- O lock otimista foi removido; o domínio não define controle de concorrência por versão.

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
- Documentação inicial do projeto em `README.md`, `docs/modelo-de-dados.md` (com diagrama ER Mermaid), `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md` e `docs/index.md`.
