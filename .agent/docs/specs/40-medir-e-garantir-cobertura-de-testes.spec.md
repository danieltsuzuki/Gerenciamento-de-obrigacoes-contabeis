# SPEC-040 — Medir e garantir cobertura de testes (backend e frontend)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Cobertura de testes** |

## 1. Objetivo

Tornar a cobertura de testes mensurável, visível e protegida contra regressões em ambos os módulos.

## 2. Situação atual

- Backend: **Atendido parcialmente** — JaCoCo 0.8.12 gera relatório (> 86% de linhas, 171 testes), mas não há limite mínimo (`check`) que falhe o build.
- Frontend: **Parcial** — 172 testes, porém a cobertura não é medida nem documentada.

## 3. Escopo funcional

- [ ] Adicionar goal `jacoco:check` no `verify` com mínimos: linhas ≥ 85% geral, ≥ 90% em `service` e `controller`.
- [ ] Corrigir caminho do relatório no README (`backend/target/site/jacoco/index.html`).
- [ ] Flutter: `flutter test --coverage`, geração de relatório HTML (`genhtml`) e script/limite mínimo (ex.: ≥ 80% de linhas, excluindo arquivos gerados e `platform_*_io/web`).
- [ ] Registrar métricas atuais do frontend em `docs/status-implementacao.md`.
- [ ] Publicar relatórios como artefatos no CI e badge de cobertura (SPEC-039).
- [ ] Identificar e cobrir classes abaixo do limite (ex.: `AttachmentService` 90.7%, `ObligationService` 93%).

## 4. Regras e restrições

- Exclusões de cobertura devem ser justificadas e documentadas (DTOs, config, `main`).
- Testes sem dependência de rede real.

## 5. Critérios de aceitação

- [ ] `./mvnw verify` falha se cobertura cair abaixo do limite.
- [ ] Cobertura do frontend documentada e ≥ limite definido.
- [ ] README explica como gerar ambos os relatórios.

## 6. Cenários de teste

- **Sucesso:** build verde com limites atendidos.
- **Validação:** remoção de testes → build falha no `check`.
- **Regressão:** relatórios gerados localmente e no CI.

## 7. Dependências

- SPEC-012, SPEC-023, SPEC-039.

## 8. Pendências

- Definir limite mínimo oficial do frontend após primeira medição.

## 9. Rastreabilidade

- `docs/status-implementacao.md`, `README.md`.

