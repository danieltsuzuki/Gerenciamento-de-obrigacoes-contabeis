# SPEC-028 — Completar README e artefatos de entrega exigidos pelo enunciado

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — README completo e links de entrega registrados |
| Tipo | Obrigatório |

## 1. Objetivo

Garantir que o `README.md` contenha **todas** as seções exigidas pelo enunciado e que a entrega registre todos os links obrigatórios.

## 2. Lacunas identificadas

| Item exigido | Situação atual |
|---|---|
| Como executar o backend | Atendido |
| Como executar o frontend | Atendido |
| Tecnologias utilizadas | Atendido (versão do Spring Boot fixada em 4.1.2) |
| Estrutura do projeto | Atendido com árvore detalhada de backend e frontend |
| Decisões arquiteturais | Atendido com resumo das 9 decisões arquiteturais e links para ADRs |
| Melhorias futuras | Atendido com roadmap detalhado das SPECs 032 a 041 |
| Seção de funcionalidades do frontend | Atendido com especificações SPEC-013 a SPEC-026 |
| Links: repositório backend, repositório frontend, PR, Trello público | Atendido com tabela completa de links de entrega |

## 3. Escopo funcional

- [x] Adicionar seção **Decisões Arquiteturais** com resumo e links para ADRs.
- [x] Adicionar seção **Melhorias Futuras** (alimentada pelas SPECs 30–40 e SPEC-041).
- [x] Atualizar a seção de funcionalidades do frontend (SPEC-013 a SPEC-026).
- [x] Detalhar a estrutura de `backend/src/main/java/...` e `frontend/lib/`.
- [x] Fixar a versão real do Spring Boot conforme `backend/pom.xml` (4.1.2).
- [x] Adicionar seção **Entrega** com links do repositório (backend e frontend), Pull Request e quadro público do Trello.
- [x] Registrar decisão: por ser monorepo, os links de "repositório backend" e "repositório frontend" apontam para o mesmo repositório (subpastas `backend/` e `frontend/`).
- [x] Atualizar o índice `.agent/docs/specs/README.md` com os status reais das SPECs.

## 4. Regras de negócio e restrições

- Nenhum segredo real em exemplos (somente placeholders).
- Documentação coerente com `check_docs.py`.

## 5. Critérios de aceitação

- [x] README contém as 6 seções obrigatórias do enunciado.
- [x] README contém os 4 links de entrega.
- [x] `check_docs.py` retorna código 0.

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

