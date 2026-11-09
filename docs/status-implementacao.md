# Status de implementação
Atualizado em: 2026-11-08

| Regra | Descrição | Estado | Implementação | Teste |
|---|---|---|---|---|
| RN-001 | CNPJ com validação de DV e normalização | Testado | `Cnpj.java`, `ValidCnpj`, `CompanyService` | `CnpjTest`, `CompanyServiceTest`, `CompanyApiIntegrationTest` |
| RN-002 | Unicidade de CNPJ no banco de dados | Testado | `V1__create_schema.sql` (`uk_company_cnpj`), `CompanyService` | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateCnpj`, `CompanyServiceTest`, `CompanyApiIntegrationTest` |
| RN-003 | Unicidade de e-mail no banco de dados | Testado | `V1__create_schema.sql` (`uk_users_email`), `ResponsibleService` | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateEmail`, `ResponsibleServiceTest`, `ResponsibleControllerTest`, `ResponsibleApiIntegrationTest` |
| RN-004 | Sem exclusão física (soft delete via campo `active`) | Testado | `Company.active`, `Responsible.active`, repositories sem `delete*`, `CompanyController`, `ResponsibleController`, `ObligationController` (sem `DELETE`, inativação via `PUT`) | `RepositoriesDoNotExposeDeleteTest`, `CompanyControllerTest`, `ResponsibleControllerTest`, `ObligationControllerTest`, `CompanyApiIntegrationTest`, `ResponsibleApiIntegrationTest`, `ObligationApiIntegrationTest` |
| RN-005 | Preservação de histórico fiscal (FKs sem `CASCADE`) | Testado | `V1__create_schema.sql` (`fk_obligation_company`, etc.) | `DatabaseMigrationIntegrationTest#shouldRefuseToDeleteCompanyWithObligations` |
| RN-006 | Inativos não recebem novas atribuições de obrigações | Testado | `ObligationService#requireActiveCompany`, `ObligationService#requireActiveResponsible` | `ObligationServiceTest`, `ObligationControllerTest`, `ObligationApiIntegrationTest` |
| RN-007 | Senha com hash seguro e fora dos DTOs de resposta | Testado | `BCryptPasswordEncoder`, `Responsible.passwordHash`, `ResponsibleResponse`, `AuthService` | `ResponsibleServiceTest`, `ResponsibleApiIntegrationTest`, `AuthControllerTest` |
| RN-008 | Ciclo de vida de status e preenchimento de `completed_at` | Testado | `ObligationStatus`, `Obligation#changeStatus`, `ObligationService#update` | `ObligationStatusTest`, `ObligationChangeStatusTest`, `ObligationServiceTest`, `ObligationControllerTest`, `ObligationApiIntegrationTest` |
| RN-009 | Armazenamento de arquivo fora do banco com metadados em `attachment` | Implementado | `Attachment`, `AttachmentRepository` | `DomainPersistenceIntegrationTest#saveAndReloadEachEntity` |

## Resumo
- **Testado:** 9
- **Implementado:** 1
- **Em andamento:** 0
- **Planejado:** 0

## Pendências e perguntas em aberto
- Pode remover ou substituir anexos de uma obrigação `COMPLETED`?
- Existe perfil/autorização (ex.: só o responsável avança o status) ou só autenticação básica?
- A obrigação tem periodicidade/recorrência automática (mensal, anual) ou cada uma é avulsa?
- Haverá status derivado "atrasada" (prazo vencido) calculado em consulta, sem novo valor no enum?
- Limite de tamanho e tipos MIME aceitos para anexos.
- CNPJ alfanumérico da Receita Federal: manter validação extensível quando for implementada.
