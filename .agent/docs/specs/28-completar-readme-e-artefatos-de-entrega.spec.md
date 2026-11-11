# SPEC-028 — Completar README e artefatos de entrega exigidos pelo enunciado

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada da validação de conformidade com o enunciado (10/11/2026) |
| Tipo | Obrigatório |

## 1. Objetivo

Garantir que o `README.md` contenha **todas** as seções exigidas pelo enunciado e que a entrega registre todos os links obrigatórios.

## 2. Lacunas identificadas

| Item exigido | Situação atual |
|---|---|
| Como executar o backend | Atendido |
| Como executar o frontend | Atendido |
| Tecnologias utilizadas | Atendido (versões do Spring Boot descritas de forma ambígua: "3.x / 4.x") |
| Estrutura do projeto | Atendido parcialmente (falta árvore de `backend/` e `frontend/lib`) |
| Decisões arquiteturais | **Parcial** — há link para ADR-0001, mas não há seção que resuma as decisões (monorepo, package by feature, soft delete, PATCH de status, JWT, storage local, Flyway, sem lib de estado no Flutter) |
| Melhorias futuras | **Ausente** |
| Seção de funcionalidades do frontend | **Desatualizada** — descreve apenas a SPEC-013 |
| Links: repositório backend, repositório frontend, PR, Trello público | **Ausentes** no README |

## 3. Escopo funcional

- [ ] Adicionar seção **Decisões Arquiteturais** com resumo e links para ADRs.
- [ ] Adicionar seção **Melhorias Futuras** (alimentada pelas SPECs 30–40 ainda não implementadas e por `docs/pendencias-e-perguntas-em-aberto.md`).
- [ ] Atualizar a seção de funcionalidades do frontend (SPEC-013 a SPEC-026).
- [ ] Detalhar a estrutura de `backend/src/main/java/...` e `frontend/lib/`.
- [ ] Fixar a versão real do Spring Boot conforme `backend/pom.xml`.
- [ ] Adicionar seção **Entrega** com links do repositório (backend e frontend), Pull Request e quadro público do Trello.
- [ ] Registrar decisão: por ser monorepo, os links de "repositório backend" e "repositório frontend" apontam para o mesmo repositório (subpastas `backend/` e `frontend/`) — ou criar ADR caso se decida separar.
- [ ] Atualizar o índice `.agent/docs/specs/README.md` com os status reais das SPECs 17–26.

## 4. Regras de negócio e restrições

- Nenhum segredo real em exemplos (somente placeholders).
- Documentação coerente com `check_docs.py`.

## 5. Critérios de aceitação

- [ ] README contém as 6 seções obrigatórias do enunciado.
- [ ] README contém os 4 links de entrega.
- [ ] `check_docs.py` retorna código 0.

## 6. Cenários de teste

- **Sucesso:** revisão manual guiada por checklist do enunciado.
- **Regressão:** `check_docs.py` sem divergências.

## 7. Dependências

- SPEC-024, SPEC-025.

## 8. Pendências e pontos a confirmar

- URL pública do quadro Trello e URL da PR final.
- Confirmar se o avaliador aceita monorepo (um link para backend e frontend).

## 9. Rastreabilidade

- `README.md`, `docs/index.md`, `docs/decisoes/`.

