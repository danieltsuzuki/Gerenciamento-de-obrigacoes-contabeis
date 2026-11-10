# Status de implementação
Atualizado em: 2026-11-10

## Regras de Negócio do Backend

| Regra | Descrição | Estado | Implementação | Teste |
|---|---|---|---|---|
| RN-001 | CNPJ com validação de DV e normalização | Testado | `Cnpj.java`, `ValidCnpj`, `CompanyService` | `CnpjTest`, `CompanyServiceTest`, `CompanyApiIntegrationTest` |
| RN-002 | Unicidade de CNPJ no banco de dados | Testado | `V1__create_schema.sql` (`uk_company_cnpj`), `CompanyService` | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateCnpj`, `CompanyServiceTest`, `CompanyApiIntegrationTest` |
| RN-003 | Unicidade de e-mail no banco de dados | Testado | `V1__create_schema.sql` (`uk_users_email`), `ResponsibleService` | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateEmail`, `ResponsibleServiceTest`, `ResponsibleControllerTest`, `ResponsibleApiIntegrationTest` |
| RN-004 | Sem exclusão física (soft delete via campo `active`) | Testado | `Company.active`, `Responsible.active`, repositories sem `delete*`, `CompanyController`, `ResponsibleController`, `ObligationController`, `AttachmentController` (sem `DELETE`, inativação via `PUT`) | `RepositoriesDoNotExposeDeleteTest`, `CompanyControllerTest`, `ResponsibleControllerTest`, `ObligationControllerTest`, `AttachmentControllerTest`, `CompanyApiIntegrationTest`, `ResponsibleApiIntegrationTest`, `ObligationApiIntegrationTest`, `AttachmentApiIntegrationTest` |
| RN-005 | Preservação de histórico fiscal (FKs sem `CASCADE`) | Testado | `V1__create_schema.sql` (`fk_obligation_company`, etc.) | `DatabaseMigrationIntegrationTest#shouldRefuseToDeleteCompanyWithObligations` |
| RN-006 | Inativos não recebem novas atribuições de obrigações | Testado | `ObligationService#requireActiveCompany`, `ObligationService#requireActiveResponsible` | `ObligationServiceTest`, `ObligationControllerTest`, `ObligationApiIntegrationTest` |
| RN-007 | Senha com hash seguro e fora dos DTOs de resposta | Testado | `BCryptPasswordEncoder`, `Responsible.passwordHash`, `ResponsibleResponse`, `AuthService` | `ResponsibleServiceTest`, `ResponsibleApiIntegrationTest`, `AuthControllerTest` |
| RN-008 | Ciclo de vida de status e preenchimento de `completed_at` | Testado | `ObligationStatus`, `Obligation#changeStatus`, `ObligationService#updateStatus`, `ObligationController#updateStatus` (`PATCH /api/obligations/{id}/status`) | `ObligationStatusTest`, `ObligationChangeStatusTest`, `ObligationServiceTest`, `ObligationControllerTest`, `ObligationApiIntegrationTest` |
| RN-009 | Armazenamento de arquivo fora do banco com metadados em `attachment` | Testado | `Attachment`, `AttachmentRepository`, `FileStorage`, `LocalFileSystemStorage`, `AttachmentService`, `AttachmentController` | `LocalFileSystemStorageTest`, `AttachmentServiceTest`, `AttachmentControllerTest`, `AttachmentApiIntegrationTest` |

## Módulos e Especificações do Frontend (Flutter)

| SPEC | Descrição | Estado | Implementação | Teste |
|---|---|---|---|---|
| SPEC-013 | Criar estrutura e navegação do Flutter | Testado | `core/config/app_config.dart`, `core/network/api_client.dart`, `core/network/api_exception.dart`, `core/routing/app_routes.dart`, `core/theme/app_theme.dart`, `core/widgets/app_scaffold.dart`, `features/company/`, `features/responsible/`, `features/obligation/` | `test/core/config/app_config_test.dart`, `test/core/network/api_client_test.dart`, `test/core/network/api_exception_test.dart`, `test/core/widgets/state_views_test.dart`, `test/features/navigation_test.dart` (14 testes aprovados) |
| SPEC-014 | Implementar camada de integração com API | Testado | `core/network/page_response.dart`, `core/network/downloaded_file.dart`, `core/network/api_client.dart` (multipart + download), `features/auth/`, `features/company/data/`, `features/responsible/data/`, `features/obligation/data/`, `features/attachment/data/` | `test/core/network/api_client_test.dart`, `test/features/auth/auth_integration_test.dart`, `test/features/company/company_integration_test.dart`, `test/features/responsible/responsible_integration_test.dart`, `test/features/obligation/obligation_integration_test.dart`, `test/features/attachment/attachment_integration_test.dart` (33 testes aprovados) |
| SPEC-015 | Criar tela de listagem de obrigações | Testado | `features/obligation/presentation/pages/obligation_list_page.dart`, `core/routing/app_routes.dart` | `test/features/obligation/obligation_list_page_test.dart`, `test/features/navigation_test.dart` (40 testes aprovados) |
| SPEC-016 | Criar listagem e formulário de empresas | Testado | `core/utils/cnpj_validator.dart`, `features/company/presentation/pages/company_form_page.dart`, `features/company/presentation/pages/company_list_page.dart` | `test/core/utils/cnpj_validator_test.dart`, `test/features/company/company_form_page_test.dart`, `test/features/company/company_list_page_test.dart` (57 testes aprovados) |
| SPEC-026 | Implementar autenticação e tela de login no Flutter | Testado | `features/auth/data/datasources/auth_session_storage.dart`, `features/auth/presentation/controllers/auth_session_controller.dart`, `features/auth/presentation/pages/login_page.dart`, `features/auth/presentation/pages/register_page.dart`, `features/auth/presentation/widgets/auth_guard.dart`, `core/widgets/app_scaffold.dart`, `core/network/api_client.dart`, `core/routing/app_routes.dart` | `test/features/auth/auth_session_storage_test.dart`, `test/features/auth/auth_session_controller_test.dart`, `test/features/auth/login_page_test.dart`, `test/features/auth/register_page_test.dart`, `test/features/auth/auth_guard_test.dart`, `test/core/widgets/app_scaffold_test.dart`, `test/features/auth/auth_integration_test.dart` (89 testes aprovados no frontend) |

## Resumo
- **Testado:** 14
- **Implementado:** 0
- **Em andamento:** 0
- **Planejado:** 0

## Cobertura de Testes (JaCoCo)
- **Plugin:** `org.jacoco:jacoco-maven-plugin:0.8.12`
- **Relatório HTML:** `target/site/jacoco/index.html`
- **Métricas Atuais:**
  - **Controllers:** 100% de linhas cobertas (`AuthController`, `CompanyController`, `ResponsibleController`, `ObligationController`, `AttachmentController`).
  - **Services:** > 92% de linhas cobertas (`CompanyService`: 97.1%, `ResponsibleService`: 100%, `ObligationService`: 93%, `AttachmentService`: 90.7%, `AuthService`: 94.7%).
  - **Segurança & Validadores:** `JwtService`/`JwtAuthenticationFilter`: 98%, `Cnpj`: 94.7%, `ObligationStatus`: 100%.
  - **Geral do Projeto:** > 86% de cobertura de linhas com 154 testes automatizados.

## Pendências e perguntas em aberto
- Pode remover ou substituir anexos de uma obrigação `COMPLETED`?
- Existe perfil/autorização (ex.: só o responsável avança o status) ou só autenticação básica?
- A obrigação tem periodicidade/recorrência automática (mensal, anual) ou cada uma é avulsa?
- Haverá status derivado "atrasada" (prazo vencido) calculado em consulta, sem novo valor no enum?
- Limite de tamanho e tipos MIME aceitos para anexos.
- CNPJ alfanumérico da Receita Federal: manter validação extensível quando for implementada.
