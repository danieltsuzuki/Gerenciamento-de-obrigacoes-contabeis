# SPEC-029 — Corrigir inconsistências de contrato e configuração de segurança

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada da validação de conformidade (10/11/2026) |
| Tipo | Obrigatório (qualidade/regras de negócio) |

## 1. Objetivo

Eliminar divergências entre documentação e implementação encontradas na validação final e remover segredo padrão da configuração.

## 2. Inconsistências identificadas

1. **Transição de status no `PUT /api/obligations/{id}`** — `docs/api.md` afirma que o PUT aceita `PENDING → COMPLETED`. A implementação (`ObligationService` → `Obligation#changeStatus`) e a regra 01 **proíbem saltos**. O enunciado exige: Pendente → Em andamento → Concluída. A documentação está incorreta.
2. **Filtros `dueFrom`/`dueTo` não documentados** — `ObligationController` aceita `dueFrom` e `dueTo` (ISO date), mas `docs/api.md` não os lista.
3. **Segredo JWT padrão** — `backend/src/main/resources/application.yml` define valor default para `jwt.secret`. Em produção, a ausência de `JWT_SECRET` deveria impedir a inicialização.
4. **Comportamento do PUT com status igual ao atual** — é ignorado silenciosamente, enquanto o PATCH rejeita com `422`. Documentar explicitamente.

## 3. Escopo funcional

- [ ] Corrigir `docs/api.md` (PUT: somente transições válidas da máquina de estados; saltos → `422 INVALID_STATUS_TRANSITION`).
- [ ] Adicionar teste de integração garantindo `PUT` com `PENDING → COMPLETED` retorna `422` (caso ainda não exista).
- [ ] Documentar `dueFrom` e `dueTo` em `GET /api/obligations`.
- [ ] Remover default de `jwt.secret` em `application.yml`/`application-prod.yml`; manter default apenas em `application-dev.yml` e testes.
- [ ] Validar tamanho mínimo do segredo (≥ 32 bytes) na inicialização com mensagem clara.
- [ ] Documentar comportamento do PUT com status igual.

## 4. Regras de negócio e restrições

- Regra 01: `COMPLETED` é terminal; não permitir saltos, regressões ou mesmo status (no PATCH).
- Regra 02: contratos de API e segurança devem refletir a implementação.

## 5. Critérios de aceitação

- [ ] `docs/api.md` coerente com a implementação; `check_docs.py` OK.
- [ ] Perfil `prod` sem `JWT_SECRET` falha na inicialização.
- [ ] Testes backend aprovados.

## 6. Cenários de teste

- **Sucesso:** PUT `PENDING → IN_PROGRESS` → 200.
- **Validação:** PUT `PENDING → COMPLETED` → 422; PUT em obrigação `COMPLETED` alterando status → 422.
- **Falha de dependência:** inicialização `prod` sem segredo → erro de configuração.
- **Regressão:** suíte existente (171 testes) continua verde.

## 7. Dependências

- SPEC-008, SPEC-009, SPEC-011.

## 8. Pendências e pontos a confirmar

- Manter ou remover a alteração de status via PUT (regra 01 exige decisão coordenada para remover).

## 9. Rastreabilidade

- `docs/api.md`, `.agent/rules/01-invariantes-do-dominio.md`, `.agent/rules/02-contrato-api-e-seguranca.md`.

