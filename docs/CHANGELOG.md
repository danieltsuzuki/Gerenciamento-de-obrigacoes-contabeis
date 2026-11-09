# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.
O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

## [Não lançado]

### Adicionado
- Endpoints REST para gerenciamento de obrigações fiscais em `/api/obligations`:
  - `POST /api/obligations`: cadastro de obrigação vinculando empresa e responsável (validação de existência e situação ativa via RN-006), definindo status padrão `PENDING` no servidor e data de criação automática. Requer autenticação.
  - `GET /api/obligations`: listagem paginada com suporte a filtros por `companyId`, `responsibleId` e `status`, retornando dados completos de exibição: empresa resumida, responsável resumido, status, contagem de anexos (`attachmentCount`) e data de criação (`createdAt`). Acesso anônimo permitido.
  - `GET /api/obligations/{id}`: busca detalhada de obrigação por ID com empresa, responsável, contagem de anexos e data de conclusão (`completedAt`). Acesso anônimo permitido.
  - `PUT /api/obligations/{id}`: atualização de título, descrição, prazo (`dueDate`), empresa/responsável (com validação RN-006 se alterados) e transição de status segundo a máquina de estados (RN-008). Requer autenticação.
  - `PATCH /api/obligations/{id}/status`: operação explícita para transição de status da obrigação seguindo a máquina de estados (RN-008), garantindo bloqueio de saltos, regressões, transições a partir de `COMPLETED` e preenchimento de `completedAt`. Requer autenticação.
- DTOs de request e response de obrigação: `CreateObligationRequest`, `UpdateObligationRequest`, `UpdateObligationStatusRequest`, `ObligationListItemResponse`, `ObligationDetailResponse`, `ObligationWithAttachmentCount`, `CompanySummaryResponse` e `ResponsibleSummaryResponse`.
- Exceção de negócio `BusinessRuleException` para violação de regras como empresa/responsável inativo (status HTTP 422).
- Camada de mapeamento `ObligationMapper` e camada de serviço `ObligationService`.
- Atualização em `AttachmentRepository` com consulta `countByObligationId(Long obligationId)`.
- Atualização em `ObligationRepository` com consulta otimizada `findWithAttachmentCountByFilters(...)` contendo subquery de contagem de anexos.
- Autenticação e Segurança com Spring Security e JWT (JJWT):
  - `POST /api/auth/register`: rota pública para autocadastro / registro de usuários responsáveis sem necessidade de autenticação prévia.
  - `POST /api/auth/login`: autenticação por e-mail e senha, retornando token Bearer e dados do usuário responsável, com tempo de expiração padrão configurado para 30 minutos (1800s).
  - Implementação de `CustomUserDetailsService` (`UserDetailsService`) para autenticação stateless no Spring Security.
  - `JwtService`: geração e validação de tokens JWT HMAC-SHA com expiração de 30 minutos por padrão (`jwt.expiration-ms=1800000`).
  - `JwtAuthenticationFilter`: interceptação de requisições stateless com cabeçalho `Authorization: Bearer <token>` e carregamento de contexto de segurança.
  - `SecurityConfig`: política de segurança stateless permitindo acesso anônimo a `GET /api/**`, `POST /api/auth/login` e `POST /api/auth/register`, e exigindo autenticação para as demais operações de mutação (`POST /api/**` e `PUT /api/**`).
  - `RestAuthenticationEntryPoint`: tratamento uniforme de 401 Unauthorized com payload JSON padronizado.
  - Hash seguro de senhas com `BCryptPasswordEncoder` (RN-007).
- Endpoints REST para gerenciamento de responsáveis em `/api/responsibles`:
  - `POST /api/responsibles`: cadastro de responsável com hash de senha, validação de e-mail único e nome obrigatório. Requer autenticação.
  - `GET /api/responsibles`: listagem com paginação padrão Spring Data (`page`, `size`, `sort`) e filtro opcional por `active`. Acesso anônimo permitido.
  - `GET /api/responsibles/{id}`: busca de responsável por ID (sem expor hash de senha). Acesso anônimo permitido.
  - `PUT /api/responsibles/{id}`: atualização de nome, e-mail e inativação/ativação (`active` para soft delete). Requer autenticação.
- DTOs de request e response: `CreateResponsibleRequest`, `UpdateResponsibleRequest`, `ResponsibleResponse`, `LoginRequest` e `LoginResponse`.
- Camada de mapeamento `ResponsibleMapper` e de serviços `ResponsibleService` e `AuthService`.
- Endpoints REST para gerenciamento de empresas em `/api/companies`:
  - `POST /api/companies`: cadastro com validação de razão social, nome fantasia e CNPJ único. Requer autenticação.
  - `GET /api/companies`: listagem com paginação padrão Spring Data (`page`, `size`, `sort`) e filtro opcional por `active`. Acesso anônimo permitido.
  - `GET /api/companies/{id}`: busca de empresa por identificador numérico. Acesso anônimo permitido.
  - `PUT /api/companies/{id}`: atualização cadastral e inativação/ativação (`active`). Requer autenticação.
- Validador puro Java `Cnpj` com normalização (apenas dígitos), descarte de sequências repetidas e cálculo estrito dos dois dígitos verificadores (DVs).
- Anotação de Bean Validation `@ValidCnpj` e validador `CnpjValidator` para validação declarativa nos DTOs.
- DTOs de request e response de empresa: `CreateCompanyRequest`, `UpdateCompanyRequest` e `CompanyResponse`.
- Camada de mapeamento `CompanyMapper` e camada de serviço `CompanyService`.
- Tratamento global de exceções via `@RestControllerAdvice` (`GlobalExceptionHandler`) com respostas padronizadas para erros de validação (400), credenciais inválidas (401), recurso não encontrado (404) e duplicidade de CNPJ/e-mail (409).
- Documentação formal dos endpoints em `docs/api.md` cobrindo segurança, login e responsáveis.
- Suíte completa de testes automatizados: unitários de validador (`CnpjTest`), segurança (`JwtServiceTest`), serviços (`CompanyServiceTest`, `ResponsibleServiceTest`), web layer (`CompanyControllerTest`, `ResponsibleControllerTest`, `AuthControllerTest`) e integração com Testcontainers MySQL 8 (`CompanyApiIntegrationTest`, `ResponsibleApiIntegrationTest`).
- Entidades JPA `Company`, `Responsible`, `Obligation` e `Attachment`, com normalização defensiva, auditoria e relações LAZY.
- Enum de ciclo de vida de obrigações, transições protegidas e repositories sem operações `delete*`.
- Migration V2 para `legal_name` e `trade_name`.
- Testes unitários do domínio e integração MySQL 8 via Testcontainers.
- ADR sobre repositories sem operações de exclusão.

### Alterado
- Acesso à API de empresas (`/api/companies`) agora protegido por autenticação JWT nas operações de mutação (`POST` e `PUT`).
- A documentação passou a refletir `Responsible`, `legalName`, `tradeName`, `storageKey` e regras de segurança JWT.
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
  4. Recusa de exclusão de empresa com obrigações vinculadas via FK sem cascade.
