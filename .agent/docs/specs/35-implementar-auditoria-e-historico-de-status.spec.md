# SPEC-035 — Implementar auditoria de operações e histórico de status

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Aprovada |
| Tipo | Diferencial (não obrigatório) — **Auditoria** |

## 1. Objetivo

Registrar quem criou/alterou cada registro e manter histórico imutável das transições de status das obrigações.

## 2. Situação atual

- **Concluído** — auditoria via Spring Data JPA (`created_by`, `updated_by`, `uploaded_by`) e histórico imutável de transições de status (`obligation_status_history`).

## 3. Escopo funcional

- [x] Nova migration Flyway adicionando `created_by`/`updated_by` (FK para `users`, nullable para registros legados e autocadastro) em `company`, `users`, `obligation`; `uploaded_by` em `attachment`.
- [x] Spring Data JPA Auditing (`@EnableJpaAuditing`, `AuditorAware` a partir do principal JWT).
- [x] Tabela `obligation_status_history` (`id`, `obligation_id`, `from_status`, `to_status`, `changed_by`, `changed_at`) sem `ON DELETE CASCADE`.
- [x] Registrar histórico na criação (`null → PENDING`) e em cada transição (PATCH e PUT).
- [x] Endpoint `GET /api/obligations/{id}/history` (leitura anônima conforme política de GET).
- [x] Expor `createdBy`/`updatedBy` (id e nome) nos DTOs de detalhe.
- [x] Flutter: linha do tempo de status na tela de detalhes da obrigação.
- [x] Atualizar `docs/api.md` e `docs/modelo-de-dados.md`.

## 4. Regras e restrições

- Histórico é somente inserção (sem update/delete — ADR-0001).
- Transição rejeitada não gera registro de histórico.
- Repositório sem métodos `delete*`.

## 5. Critérios de aceitação

- [x] Toda transição válida gera exatamente um registro de histórico.
- [x] Autor registrado corresponde ao usuário do token.
- [x] Testes de migration (Testcontainers), serviço, controller e widget.
- [x] `check_docs.py` OK.

## 6. Cenários de teste

- **Sucesso:** PENDING → IN_PROGRESS → COMPLETED gera 3 registros (incluindo criação).
- **Validação:** transição inválida (422) não gera registro.
- **Falha de dependência:** falha ao gravar histórico desfaz a transição (mesma transação).
- **Regressão:** máquina de estados inalterada.

## 7. Dependências

- SPEC-004, SPEC-009, SPEC-019.

## 8. Pendências

- Definir se alterações de campos (título, prazo) também devem ter trilha detalhada (ex.: Hibernate Envers).

## 9. Rastreabilidade

- `docs/modelo-de-dados.md`, `docs/api.md`, ADR-0001.

