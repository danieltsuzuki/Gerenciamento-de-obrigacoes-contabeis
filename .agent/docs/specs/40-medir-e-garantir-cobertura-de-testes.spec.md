# SPEC-040 — Medir e garantir cobertura de testes (backend e frontend)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído / Testado |
| Versão da SPEC | 1.0 |
| Situação da especificação | Concluído |
| Tipo | Diferencial (não obrigatório) — **Cobertura de testes** |

## 1. Objetivo

Tornar a cobertura de testes mensurável, visível e protegida contra regressões em ambos os módulos (backend Spring Boot e frontend Flutter), com thresholds mínimos automatizados que falham a compilação/pipeline caso a cobertura caia.

## 2. Situação atual

- Backend: **Concluído / Testado** — JaCoCo 0.8.12 configurado com goal `check` no ciclo `verify` com regras estritas: mínimo geral (BUNDLE) ≥ 85%, classes de controller ≥ 90% e classes de service ≥ 90%. Total geral atingido: 87.17% (202 testes automatizados aprovados, 0 falhas).
- Frontend: **Concluído / Testado** — 199 testes automatizados aprovados com `flutter test --coverage`. Script `frontend/tool/check_coverage.py` analisa `coverage/lcov.info` e valida o threshold mínimo oficial de 80.00%. Cobertura geral atingida: 82.14% (3.026 de 3.684 linhas cobertas).

## 3. Escopo funcional

- [x] Adicionar goal `jacoco:check` no ciclo `verify` com mínimos: linhas ≥ 85% geral, ≥ 90% em `service` e `controller`.
- [x] Corrigir e documentar o caminho do relatório no README (`backend/target/site/jacoco/index.html`).
- [x] Flutter: `flutter test --coverage` e ferramenta/script de validação de threshold (`frontend/tool/check_coverage.py`, threshold padrão ≥ 80.00%).
- [x] Registrar métricas de cobertura de ambos os módulos em `docs/status-implementacao.md`.
- [x] Identificar e cobrir classes com lacunas de teste (`AuthServiceTest` cobrindo 100% de linhas e novos testes de casos de borda em `LocalFileSystemStorageTest`).
- [x] Validar que o build falha quando o limite não é atingido (validado com simulação de 99% no JaCoCo e `--threshold 99` no Flutter).

## 4. Regras e restrições

- Exclusões de cobertura documentadas e justificadas:
  - Backend: classes de bootstrap do Spring (`PlayerContabilidadeBackApplication`, `ServletInitializer`), DTOs e classes de infraestrutura pura (`**/shared/config/**`).
  - Frontend: ponto de entrada do Flutter (`lib/main.dart`) e plugins de canal nativo do sistema operacional (`platform_file_picker_io.dart` e `platform_file_saver_io.dart`).
- Testes completamente autocontidos, sem dependência de rede externa.

## 5. Critérios de aceitação

- [x] `./mvnw verify` ou `./mvnw jacoco:check` é executado com sucesso e falha se a cobertura de linhas cair abaixo dos limites mínimos (BUNDLE ≥ 85%, Controllers ≥ 90%, Services ≥ 90%).
- [x] Cobertura do frontend medida via `flutter test --coverage` e validada por `python tool/check_coverage.py` com limite ≥ 80.00%.
- [x] Documentação e READMEs explicam claramente como rodar testes e verificar limites de cobertura em ambos os módulos.

## 6. Cenários de teste

- **Sucesso:** build verde e relatórios gerados com limites superados (Backend: 87.17% ≥ 85%, Frontend: 82.14% ≥ 80%).
- **Validação de Falha:** simulação com threshold superior à cobertura atual gera `BUILD FAILURE` no Maven e código de saída `1` no script do Flutter.
- **Regressão:** suíte completa de 202 testes no backend e 199 testes no frontend aprovada sem falhas ou warnings de contrato.

## 7. Dependências

- SPEC-012, SPEC-023, SPEC-039.

## 8. Pendências

- Nenhuma pendência em aberto. O limite mínimo do frontend foi medido e fixado em 80.00% (alcançando 82.14%).

## 9. Rastreabilidade

- `backend/pom.xml` (`jacoco-maven-plugin`), `backend/src/test/java/.../AuthServiceTest.java`, `frontend/tool/check_coverage.py`, `docs/status-implementacao.md`, `README.md`, `backend/README.md`, `frontend/README.md`.
