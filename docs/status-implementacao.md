# Status de implementação
Atualizado em: 2026-11-07

| Regra | Descrição | Estado | Implementação | Teste |
|---|---|---|---|---|
| RN-001 | CNPJ com validação de DV e normalização | Planejado | — | — |
| RN-002 | Unicidade de CNPJ no banco de dados | Testado | `V1__create_schema.sql` (`uk_company_cnpj`) | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateCnpj` |
| RN-003 | Unicidade de e-mail no banco de dados | Testado | `V1__create_schema.sql` (`uk_users_email`) | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateEmail` |
| RN-004 | Sem exclusão física (soft delete via campo `active`) | Implementado | `Company.active`, `Responsible.active`, repositories sem `delete*` | `RepositoriesDoNotExposeDeleteTest` |
| RN-005 | Preservação de histórico fiscal (FKs sem `CASCADE`) | Testado | `V1__create_schema.sql` (`fk_obligation_company`, etc.) | `DatabaseMigrationIntegrationTest#shouldRefuseToDeleteCompanyWithObligations` |
| RN-006 | Inativos não recebem novas atribuições de obrigações | Planejado | — | — |
| RN-007 | Senha com hash seguro e fora dos DTOs de resposta | Planejado | — | — |
| RN-008 | Ciclo de vida de status e preenchimento de `completed_at` | Testado | `ObligationStatus`, `Obligation#changeStatus` | `ObligationStatusTest`, `ObligationChangeStatusTest` |
| RN-009 | Armazenamento de arquivo fora do banco com metadados em `attachment` | Implementado | `Attachment`, `AttachmentRepository` | `DomainPersistenceIntegrationTest#saveAndReloadEachEntity` |

## Resumo
- **Testado:** 6
- **Implementado:** 2
- **Em andamento:** 0
- **Planejado:** 2

## Pendências e perguntas em aberto
- Pode remover ou substituir anexos de uma obrigação `COMPLETED`?
- Existe perfil/autorização (ex.: só o responsável avança o status) ou só autenticação básica?
- A obrigação tem periodicidade/recorrência automática (mensal, anual) ou cada uma é avulsa?
- Haverá status derivado "atrasada" (prazo vencido) calculado em consulta, sem novo valor no enum?
- Limite de tamanho e tipos MIME aceitos para anexos.
- CNPJ alfanumérico da Receita Federal: manter validação extensível quando for implementada.
