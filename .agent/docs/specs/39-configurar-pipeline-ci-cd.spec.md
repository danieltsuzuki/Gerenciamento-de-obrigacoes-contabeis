# SPEC-039 — Configurar pipeline de CI/CD

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **CI/CD** |

## 1. Objetivo

Validar automaticamente cada push/PR e publicar artefatos da aplicação.

## 2. Situação atual

- **Ausente** — não existe diretório `.github/workflows` nem outro pipeline.

## 3. Escopo funcional

- [ ] Workflow `ci.yml` (GitHub Actions) disparado em `push` e `pull_request` para `master`:
  - Job **backend**: `actions/setup-java` (Temurin 21, cache Maven), `./mvnw verify` (Testcontainers usa Docker do runner), upload do relatório JaCoCo.
  - Job **frontend**: `subosito/flutter-action` (versão fixada no README), `flutter pub get`, `flutter analyze`, `flutter test --coverage`, upload de `coverage/lcov.info`.
  - Job **docs**: `python .agent/skills/documentacao-projeto/scripts/check_docs.py .`.
  - Filtros por caminho (`backend/**`, `frontend/**`, `docs/**`).
- [ ] Workflow `cd.yml` em tags `v*` ou merge em `master`: build e push das imagens Docker (SPEC-030) para GHCR; build Flutter Web como artefato.
- [ ] Proteção da branch `master` exigindo CI verde para merge (documentar).
- [ ] Badges de status no README.

## 4. Regras e restrições

- Segredos somente via GitHub Secrets (`GITHUB_TOKEN` para GHCR); nada em YAML.
- Não fazer deploy em ambiente externo sem decisão explícita.

## 5. Critérios de aceitação

- [ ] PR mostra checks backend, frontend e docs.
- [ ] Falha em teste/analyze bloqueia o merge.
- [ ] Imagens publicadas com tag de versão e `latest`.

## 6. Cenários de teste

- **Sucesso:** PR válida → todos os jobs verdes.
- **Validação:** teste quebrado propositalmente → job vermelho.
- **Falha de dependência:** indisponibilidade do Docker no runner → falha explícita do job backend.
- **Regressão:** tempo de pipeline aceitável com cache.

## 7. Dependências

- SPEC-012, SPEC-023, SPEC-030, SPEC-040.

## 8. Pendências

- Confirmar plataforma (GitHub Actions assumido por o repositório estar no GitHub).

## 9. Rastreabilidade

- `README.md`, `.github/workflows/`.

