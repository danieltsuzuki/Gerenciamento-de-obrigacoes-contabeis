# Status de implementação
Atualizado em: 2026-11-07

| Regra | Descrição | Estado | Implementação | Teste |
|---|---|---|---|---|
| RN-001 | CNPJ com validação de DV e normalização | Planejado | — | — |
| RN-002 | Unicidade de CNPJ no banco de dados | Testado | `V1__create_schema.sql` (`uk_company_cnpj`) | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateCnpj` |
| RN-003 | Unicidade de e-mail no banco de dados | Testado | `V1__create_schema.sql` (`uk_users_email`) | `DatabaseMigrationIntegrationTest#shouldRejectDuplicateEmail` |
| RN-004 | Sem exclusão física (soft delete via campo `active`) | Implementado (banco) | `V1__create_schema.sql` (`active BOOLEAN`) | — |
| RN-005 | Preservação de histórico fiscal (FKs sem `CASCADE`) | Testado | `V1__create_schema.sql` (`fk_obligation_company`, etc.) | `DatabaseMigrationIntegrationTest#shouldRefuseToDeleteCompanyWithObligations` |
| RN-006 | Inativos não recebem novas atribuições de obrigações | Planejado | — | — |
| RN-007 | Senha com hash seguro e fora dos DTOs de resposta | Planejado | — | — |
| RN-008 | Ciclo de vida de status e preenchimento de `completed_at` | Planejado (check constraint no banco) | `V1__create_schema.sql` (`ck_obligation_status`) | — |
| RN-009 | Armazenamento de arquivo fora do banco com metadados em `attachment` | Planejado (tabela no banco) | `V1__create_schema.sql` | — |

## Resumo
- **Testado:** 3
- **Implementado (banco):** 1
- **Em andamento:** 0
- **Planejado:** 5

## Pendências e perguntas em aberto
- Pode remover ou substituir anexos de uma obrigação `COMPLETED`?
- Existe perfil/autorização (ex.: só o responsável avança o status) ou só autenticação básica?
- A obrigação tem periodicidade/recorrência automática (mensal, anual) ou cada uma é avulsa?
- Haverá status derivado "atrasada" (prazo vencido) calculado em consulta, sem novo valor no enum?
- Limite de tamanho e tipos MIME aceitos para anexos.
- CNPJ alfanumérico da Receita Federal: manter validação extensível quando for implementada.

