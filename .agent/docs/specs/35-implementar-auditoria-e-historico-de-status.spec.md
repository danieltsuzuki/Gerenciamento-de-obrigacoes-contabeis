# SPEC-035 — Implementar auditoria de operações e histórico de status

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Auditoria** |

## 1. Objetivo

Registrar quem criou/alterou cada registro e manter histórico imutável das transições de status das obrigações.

## 2. Situação atual

- **Parcial** — existem `created_at`/`updated_at` (MySQL `ON UPDATE CURRENT_TIMESTAMP`) e `completed_at`; não há autor da operação nem histórico.

## 3. Escopo funcional

- [ ] Nova migration Flyway adicionando `created_by`/`updated_by` (FK para `users`, nullable para registros legados e autocadastro) em `company`, `users`, `obligation`; `uploaded_by` em `attachment`.
- [ ] Spring Data JPA Auditing (`@EnableJpaAuditing`, `AuditorAware` a partir do principal JWT).
- [ ] Tabela `obligation_status_history` (`id`, `obligation_id`, `from_status`, `to_status`, `changed_by`, `changed_at`) sem `ON DELETE CASCADE`.
- [ ] Registrar histórico na criação (`null → PENDING`) e em cada transição (PATCH e PUT).
- [ ] Endpoint `GET /api/obligations/{id}/history` (leitura anônima conforme política de GET).
- [ ] Expor `createdBy`/`updatedBy` (id e nome) nos DTOs de detalhe.
- [ ] Flutter: linha do tempo de status na tela de detalhes da obrigação.
- [ ] Atualizar `docs/api.md` e `docs/modelo-de-dados.md`.

## 4. Regras e restrições

- Histórico é somente inserção (sem update/delete — ADR-0001).
- Transição rejeitada não gera registro de histórico.
- Repositório sem métodos `delete*`.

## 5. Critérios de aceitação

- [ ] Toda transição válida gera exatamente um registro de histórico.
- [ ] Autor registrado corresponde ao usuário do token.
- [ ] Testes de migration (Testcontainers), serviço, controller e widget.
- [ ] `check_docs.py` OK.

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

