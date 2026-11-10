# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.
O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

## [Não lançado]

### Alterado
- Atualização e alinhamento da documentação e READMEs:
  - Expansão do `README.md` raiz detalhando a stack do frontend, comandos para executar a aplicação Flutter (`flutter run`), testes (`flutter test`) e análise estática (`flutter analyze`).
  - Criação do `backend/README.md` com instruções específicas do módulo Spring Boot e integração com o `.env` na raiz.
  - Reestruturação completa do `frontend/README.md` com arquitetura em camadas, Clean Architecture, injeção de parâmetros (`--dart-define=API_URL=...`) e guia de testes.
  - Atualização do `docs/arquitetura.md` refletindo com precisão a estrutura de diretórios implementada na SPEC-013 e mapeamento das próximas features.
  - Atualização do `docs/status-implementacao.md` incluindo o rastreamento formal das especificações e testes do Flutter.
- Centralização dos arquivos de ambiente e contêineres na raiz do repositório:
  - Movimentação de `Dockerfile`, `.env` e `.env.example` para a raiz do projeto para compartilhamento entre backend e frontend.
  - Inclusão da variável `API_URL` no `.env.example` para configuração do cliente frontend Flutter.
  - Atualização do `README.md` refletindo o fluxo de configuração unificado.
- Reestruturação do repositório em formato monorepo:
  - Movimentação do código da aplicação Spring Boot para a pasta `/backend` (`src`, `pom.xml`, wrappers Maven, `.env.example`, `Dockerfile`).
  - Criação da pasta `/frontend` para a aplicação Flutter.
  - Manutenção da documentação unificada (`/docs`) e das diretrizes e especificações do agente (`/.agent`) na raiz do repositório para atender a ambos os módulos.
  - Atualização do script `check_docs.py` e do `.gitignore` para suporte transparente à estrutura monorepo.

### Adicionado
- Configuração de Cross-Origin Resource Sharing (CORS) no backend Spring Boot:
  - Habilitação de suporte a CORS no `SecurityConfig` via bean `CorsConfigurationSource` e liberação pública de requisições pre-flight `OPTIONS /**`.
  - Configuração parametrizável através da propriedade `cors.allowed-origin-patterns` e variável de ambiente `CORS_ALLOWED_ORIGIN_PATTERNS` (padrão: `http://localhost:*,http://127.0.0.1:*`), viabilizando a integração direta com clientes web como Flutter Web.
  - Suporte a credenciais (`allowCredentials: true`), todos os métodos HTTP (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `HEAD`), cabeçalhos abertos (`*`), cabeçalhos expostos (`Authorization`, `Content-Disposition`, `Location`) e cache de pre-flight de 3600 segundos (1 hora).
  - Criação da suíte de testes automatizados `CorsConfigurationTest` validando a correta instanciação e filtros de origens.
  - Documentação em `docs/arquitetura.md`, `docs/api.md`, `README.md` e `backend/README.md`.
- Implementação e validação da SPEC-013 (Criar estrutura e navegação do Flutter):
  - Inicialização do projeto Flutter 3.29.1 / Dart 3.7.0 no diretório `/frontend`.
  - Arquitetura limpa modular orientada a features (`features/company`, `features/responsible`, `features/obligation`) dividida estritamente em camadas `data`, `domain` e `presentation`.
  - Configuração de ambiente dinâmica (`AppConfig`) com suporte a `--dart-define=API_URL=...` e ambientes dev/staging/prod sem hardcoding de URLs.
  - Cliente HTTP customizado (`ApiClient`) desacoplado com tratamento de exceções mapeado para o contrato REST do backend (`ApiException`), suporte a token JWT Bearer e timeouts configuráveis.
  - Design system Material 3 padronizado (`AppTheme`) com paleta institucional e componentes compartilhados para feedback visual: `LoadingStateView`, `ErrorStateView`, `EmptyStateView` e layout responsivo adaptativo com `AppScaffold` (`NavigationRail` para desktop/web e `Drawer`/`NavigationBar` para telas menores).
  - Configuração de rotas nomeadas com injeção de dependências e páginas iniciais de listagem (`CompanyListPage`, `ResponsibleListPage`, `ObligationListPage` com filtro de status e chips temáticos).
  - Cobertura com suíte de testes unitários e de widget no Flutter (`flutter test`), totalizando 14 testes com 100% de sucesso e zero alertas no `flutter analyze`.
  - Fechamento formal dos critérios de aceite da SPEC-013.
- Validação e formalização da SPEC-012 (Adicionar testes do backend):
  - Cobertura abrangente com suíte de testes automatizados cobrindo domínio, serviços, controllers, segurança, validações e persistência.
  - Execução de 149 testes unitários e de fatiamento WebMvc com 100% de sucesso.
  - Testes de integração ponta a ponta com Testcontainers MySQL 8 (`CompanyApiIntegrationTest`, `ResponsibleApiIntegrationTest`, `ObligationApiIntegrationTest`, `AttachmentApiIntegrationTest`, `DatabaseMigrationIntegrationTest`, `DomainPersistenceIntegrationTest`, `OpenApiIntegrationTest`, `ActuatorHealthTest`).
  - Geração automatizada de relatórios de cobertura com JaCoCo 0.8.12 (`target/site/jacoco/index.html`), atingindo 100% de cobertura nos controllers e mais de 86% no backend global.
  - Fechamento formal dos critérios de aceite da SPEC-012.
- Validação e formalização da SPEC-011 (Padronizar DTOs, validações e tratamento de exceções):
  - Isolamento estrito entre DTOs e entidades JPA em todas as camadas de apresentação e persistência.
  - Validação de entrada via Bean Validation nos payloads de requisição com respostas `400 VALIDATION_ERROR` detalhadas.
  - Tratamento global de exceções via `GlobalExceptionHandler` padronizando respostas para `400`, `401`, `404`, `409`, `422`, `405` e `500` via estrutura `ErrorResponse`.
  - Tratamento genérico de exceções não mapeadas retornando `500 INTERNAL_SERVER_ERROR` sem expor stack traces ou detalhes sensíveis.
  - Criação da suíte unitária `GlobalExceptionHandlerTest` com cobertura completa de todos os fluxos de tratamento de erros.
  - Fechamento formal dos critérios de aceite da SPEC-011.
- Validação e formalização da SPEC-010 (Implementar upload e listagem de anexos - API):
  - Validação dos endpoints REST para anexos: `POST /api/obligations/{id}/attachments` (upload multipart), `GET /api/obligations/{id}/attachments` (metadados) e `GET /api/attachments/{attachmentId}/download` (download via streaming).
  - Validação da arquitetura de armazenamento desacoplada via `FileStorage` e `LocalFileSystemStorage`, com isolamento de diretório, geração de storageKey via UUID, prevenção contra *Path Traversal* e compensação com deleção física do arquivo no filesystem caso a persistência relacional falhe.
  - Validação de restrições de segurança e tamanho: limite de 10 MB, validação de MIME types permitidos e exigência de autenticação JWT em todos os endpoints de anexos.
  - Fechamento formal dos critérios de aceite da SPEC-010.
- Validação e formalização da SPEC-009 (Implementar máquina de estados da obrigação):
  - Validação do endpoint `PATCH /api/obligations/{id}/status` e regra de transições estritas: `PENDING` -> `IN_PROGRESS` -> `COMPLETED`.
  - Validação do bloqueio a nível de domínio e API para saltos de estado, regressões, reabertura de obrigações concluídas e repetição do mesmo status (422 INVALID_STATUS_TRANSITION).
  - Validação do preenchimento automático e auditável de `completedAt` exclusivamente ao atingir `COMPLETED`.
  - Fechamento formal dos critérios de aceite da SPEC-009.
- Validação e formalização da SPEC-008 (Implementar cadastro e consulta de obrigações - API):
  - Validação dos endpoints REST em `/api/obligations` (`POST`, `GET`, `GET /{id}`, `PUT /{id}`).
  - Validação de regras de negócio: inicialização forçada em `PENDING`, bloqueio de atribuição para participantes inativos (RN-006 com HTTP 422) e contagem de anexos (`attachmentCount`) na listagem paginada.
  - Fechamento formal dos critérios de aceite da SPEC-008.
- Validação e formalização da SPEC-007 (Implementar cadastro e consulta de responsáveis - API):
  - Validação dos endpoints REST em `/api/responsibles` (`POST`, `GET`, `GET /{id}`, `PUT /{id}`) e `/api/auth` (`POST /register`, `POST /login`).
  - Validação de segurança com senhas hashadas via `BCrypt`, ocultação de hash nos DTOs de resposta, validação de e-mail único e bloqueio de login para inativos.
  - Fechamento formal dos critérios de aceite da SPEC-007.
- Validação e formalização da SPEC-006 (Implementar cadastro e consulta de empresas - API):
  - Validação dos endpoints REST em `/api/companies` (`POST`, `GET`, `GET /{id}`, `PUT /{id}`).
  - Validação de regras de negócio de CNPJ (normalização para somente dígitos, validação de dois dígitos verificadores via `Cnpj` e unicidade).
  - Validação de exclusão lógica (soft delete via `active: false`) e bloqueio de métodos `DELETE` (405 Method Not Allowed).
  - Fechamento formal dos critérios de aceite da SPEC-006.
- Validação e formalização da SPEC-005 (Implementar entidades e mapeamentos JPA):
  - Validação das entidades `Company`, `Responsible`, `Obligation`, `Attachment` e enum `ObligationStatus`.
  - Validação dos mapeamentos relacionais ManyToOne com fetch LAZY e `optional = false`, sem cascatas de remoção ou orphanRemoval.
  - Validação da ADR-0001 via teste de reflexão `RepositoriesDoNotExposeDeleteTest` (nenhum repository declara ou herda métodos `delete*`).
- Validação e formalização da SPEC-004 (Configurar MySQL e migrations com Flyway):
  - Validação do esquema relacional versionado via Flyway (`V1__create_schema.sql` e `V2__align_domain_names.sql`) para as tabelas `company`, `users`, `obligation` e `attachment`.
  - Validação de constraints de integridade referencial (`ON DELETE RESTRICT`, sem cascata), unicidade de CNPJ (`uk_company_cnpj`), unicidade de e-mail (`uk_users_email`) e checagem de status da obrigação (`ck_obligation_status`).
  - Validação de execução de migrações e garantia de integridade com Testcontainers MySQL 8 (`DatabaseMigrationIntegrationTest`).
- Conclusão e formalização da SPEC-003 (Criar repositório e estrutura do backend):
  - Liberação do endpoint de health check (`/actuator/health`, `/actuator/health/**`, `/actuator/info`) como público no `SecurityConfig` para sondas de liveness/readiness e monitoramento.
  - Configuração de exposição de endpoints de gerenciamento no `application.yml` (`management.endpoints.web.exposure.include=health,info`).
  - Criação do teste de integração `ActuatorHealthTest` validando a resposta do status `UP` sem exigência de autenticação.
- Validação e formalização da SPEC-002 (Modelar domínio e relacionamentos):
  - Validação das entidades JPA (`Company`, `Responsible`, `Obligation`, `Attachment`) e seus relacionamentos (Company 1:N Obligation, Responsible 1:N Obligation, Obligation 1:N Attachment com `@ManyToOne(fetch = LAZY, optional = false)`).
  - Atualização de notas de autenticação em `docs/modelo-de-dados.md` e fechamento formal dos critérios de aceite da SPEC-002.
- Formalização e conclusão da SPEC-001 (Arquitetura, Escopo do MVP e Convenções):
  - Criação do documento mestre `docs/arquitetura.md` definindo os limites do MVP (o que está dentro e fora do escopo), organização em camadas e *Package-by-Feature* no backend e *Feature-First / Clean Architecture* no frontend Flutter.
  - Documentação da estratégia de armazenamento local de anexos desacoplada (`FileStorage` + `LocalFileSystemStorage`), isolamento por UUID, proteção contra *Path Traversal* e compensação no filesystem em caso de falha de persistência no MySQL.
  - Registro de convenções REST, JSON em camelCase, datas em ISO-8601, paginação via DTO e padronização uniforme de erros.
  - Atualização completa do `README.md` raiz com visão geral, arquitetura, stack, instruções de execução, autenticação, Swagger UI e relatórios JaCoCo.
  - Saneamento de pendências técnicas resolvidas em `docs/pendencias-e-perguntas-em-aberto.md` e atualização da rastreabilidade da SPEC-001 para Concluído.
- Cobertura de testes automatizados com JaCoCo (`jacoco-maven-plugin` 0.8.12):
  - Geração automática de relatórios de cobertura em HTML (`target/site/jacoco/index.html`), CSV e XML a cada execução de `mvn test`.
  - Exclusão de classes utilitárias de infraestrutura (`ServletInitializer`, `PlayerContabilidadeBackApplication`, DTOs e classes de configuração) para focar a medição nas regras de negócio e contratos de API.
  - Alcance de mais de 86% de cobertura de linhas no projeto geral e 100% de cobertura nos controllers da aplicação.
- Documentação interativa da API com Swagger UI / OpenAPI 3 (`springdoc-openapi-starter-webmvc-ui` 2.8.5):
  - Interface visual disponível em `/swagger-ui.html` e `/swagger-ui/index.html`.
  - Contrato OpenAPI 3.0 disponível em `/v3/api-docs`.
  - Suporte completo a autenticação Bearer JWT no Swagger UI via esquema de segurança `bearerAuth`, permitindo autorizar o client com o token gerado em `/api/auth/login` e testar operações restritas diretamente pelo navegador.
  - Anotações OpenAPI detalhadas (`@Tag`, `@Operation`, `@ApiResponses`, `@Parameter`, `@Schema`) em todos os controllers e DTOs (`AuthController`, `CompanyController`, `ResponsibleController`, `ObligationController`, `AttachmentController`).
  - Liberação pública das rotas de documentação no `SecurityConfig` sem necessidade de login.
  - Testes de integração automatizados em `OpenApiIntegrationTest`.
- Endpoints REST para gerenciamento de anexos de obrigações fiscais:
  - `POST /api/obligations/{id}/attachments`: upload multipart (`multipart/form-data`) de arquivos vinculados à obrigação, com validação de tipo MIME seguro, nome e tamanho máximo (10MB), gerando identificador interno seguro contra path traversal e gravando metadados no MySQL. Requer autenticação JWT.
  - `GET /api/obligations/{id}/attachments`: listagem dos anexos vinculados a uma obrigação com dados completos de metadados. Requer autenticação JWT.
  - `GET /api/attachments/{attachmentId}/download`: download seguro de arquivo binário com cabeçalhos `Content-Type` e `Content-Disposition` devidamente sanitizados. Requer autenticação JWT.
- Camada de armazenamento desacoplada: interface `FileStorage` e implementação `LocalFileSystemStorage` com diretório configurável (`storage.location`), proteção contra path traversal e mecanismo de compensação para deleção de arquivo físico em caso de erro na persistência do banco.
- DTOs e mapeamento de anexo: `AttachmentResponse`, `DownloadedFile` e `AttachmentMapper`.
- Tratamento de exceções com `StorageException` (500) e `InvalidFileException` (400) no `GlobalExceptionHandler`.
- Suíte de testes automatizados para anexos: unitários de storage (`LocalFileSystemStorageTest`), serviço (`AttachmentServiceTest`), WebMvc (`AttachmentControllerTest`) e integração com Testcontainers MySQL 8 (`AttachmentApiIntegrationTest`).
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
