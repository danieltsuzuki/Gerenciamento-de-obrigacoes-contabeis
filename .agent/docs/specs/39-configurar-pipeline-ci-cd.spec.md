# SPEC-039 — Configurar pipeline de CI/CD

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído / Testado |
| Versão da SPEC | 1.0 |
| Situação da especificação | Concluído |
| Tipo | Diferencial (não obrigatório) — **CI/CD** |

## 1. Objetivo

Validar automaticamente cada push/PR e publicar artefatos da aplicação via workflows do GitHub Actions, assegurando testes, análise estática, cobertura e empacotamento contínuo.

## 2. Situação atual

- **Concluído / Testado** — Diretório `.github/workflows/` criado contendo:
  - `ci.yml`: jobs automatizados para Backend (Java 21, Maven verify com Testcontainers, JaCoCo check), Frontend (Flutter 3.29.1, pub get, analyze, test com coverage e verificação de threshold ≥ 80%) e Docs (`check_docs.py`).
  - `cd.yml`: jobs automatizados para build e publicação de imagens no GitHub Container Registry (`ghcr.io`) e geração de bundle de release do Flutter Web.
  - Badges de CI/CD e testes inseridos no topo do `README.md`.
  - Regras de proteção de branch documentadas.

## 3. Escopo funcional

- [x] Workflow `ci.yml` (GitHub Actions) disparado em `push` e `pull_request` para `master` e `main`:
  - Job **backend**: `actions/setup-java` (Temurin 21, cache Maven), `./mvnw verify` (Testcontainers usa Docker nativo do runner), upload do relatório JaCoCo (`backend/target/site/jacoco/`).
  - Job **frontend**: `subosito/flutter-action` (versão 3.29.1, estável), `flutter pub get`, `flutter analyze`, `flutter test --coverage`, verificação de limites com `python tool/check_coverage.py` e upload do relatório de cobertura.
  - Job **docs**: `python .agent/skills/documentacao-projeto/scripts/check_docs.py .`.
- [x] Workflow `cd.yml` em tags `v*` ou branches principais (`master`/`main`): build e push das imagens Docker (SPEC-030) para GHCR (`ghcr.io/danieltsuzuki/player-contabilidade-backend` e `player-contabilidade-frontend`); build Flutter Web como artefato arquivado.
- [x] Proteção da branch principal exigindo CI verde para merge (documentada no `README.md`).
- [x] Badges de status e métricas de cobertura no `README.md`.

## 4. Regras e restrições

- Segredos somente via GitHub Secrets (`GITHUB_TOKEN` para autenticação no GHCR); sem credenciais hardcoded nos arquivos YAML.
- Concurrency configurada para cancelamento automático de execuções redundantes na mesma branch.
- Docker Buildx configurado com cache multi-stage GitHub Actions (`type=gha`).

## 5. Critérios de aceitação

- [x] PRs disparam automaticamente os checks de backend, frontend e documentação.
- [x] Falha em testes, linter ou threshold de cobertura bloqueia a execução do pipeline.
- [x] Workflows de CD publicam imagens com versionamento semântico, ref de branch e tag `latest`.

## 6. Cenários de teste

- **Sintaxe e Estrutura dos Workflows:** Arquivos YAML válidos de acordo com o schema de workflows do GitHub Actions.
- **Validação Local dos Comandos do CI:** `./mvnw clean verify`, `flutter analyze`, `flutter test --coverage`, `python tool/check_coverage.py` e `python check_docs.py` todos aprovados com saída 0.
- **Isolamento de Credenciais:** `secrets.GITHUB_TOKEN` utilizado estritamente para o registro GHCR.

## 7. Dependências

- SPEC-012, SPEC-023, SPEC-030, SPEC-040.

## 8. Pendências

- Nenhuma pendência em aberto.

## 9. Rastreabilidade

- `.github/workflows/ci.yml`, `.github/workflows/cd.yml`, `README.md`, `docs/status-implementacao.md`, `docs/CHANGELOG.md`.
