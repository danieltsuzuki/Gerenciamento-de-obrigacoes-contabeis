# SPEC-029 — Corrigir inconsistências de contrato e configuração de segurança

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — contrato corrigido, filtros documentados e segurança endurecida |
| Tipo | Obrigatório (qualidade/regras de negócio) |

## 1. Objetivo

Eliminar divergências entre documentação e implementação encontradas na validação final e remover segredo padrão da configuração.

## 2. Inconsistências identificadas

1. **Transição de status no `PUT /api/obligations/{id}`** — `docs/api.md` corrigido: PUT segue a máquina de estados estrita (saltos e regressões retornam 422).
2. **Filtros `dueFrom`/`dueTo` não documentados** — documentados na tabela de parâmetros de `GET /api/obligations`.
3. **Segredo JWT padrão** — removido default inseguro em `application.yml`, validado tamanho mínimo (≥ 32 bytes) em `JwtService` com `IllegalArgumentException` e default mantido estritamente para `dev` e testes.
4. **Comportamento do PUT com status igual ao atual** — documentado que é tratado como atualização cadastral (no-op de status).

## 3. Escopo funcional

- [x] Corrigir `docs/api.md` (PUT: somente transições válidas da máquina de estados; saltos → `422 INVALID_STATUS_TRANSITION`).
- [x] Adicionar teste de integração garantindo `PUT` com `PENDING → COMPLETED` retorna `422` (implementado em `ObligationApiIntegrationTest`).
- [x] Documentar `dueFrom` e `dueTo` em `GET /api/obligations`.
- [x] Remover default de `jwt.secret` em `application.yml`/`application-prod.yml`; manter default apenas em `application-dev.yml` e testes.
- [x] Validar tamanho mínimo do segredo (≥ 32 bytes) na inicialização com mensagem clara (testado em `JwtServiceTest`).
- [x] Documentar comportamento do PUT com status igual.

## 4. Regras de negócio e restrições

- Regra 01: `COMPLETED` é terminal; não permitir saltos, regressões ou mesmo status (no PATCH).
- Regra 02: contratos de API e segurança devem refletir a implementação.

## 5. Critérios de aceitação

- [x] `docs/api.md` coerente com a implementação; `check_docs.py` OK.
- [x] Perfil `prod` sem `JWT_SECRET` falha na inicialização.
- [x] Testes backend aprovados.

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

