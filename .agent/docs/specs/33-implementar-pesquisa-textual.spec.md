# SPEC-033 — Implementar pesquisa textual (API e Flutter)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída |
| Tipo | Diferencial (não obrigatório) — **Pesquisa** |

## 1. Objetivo

Permitir localizar rapidamente empresas, responsáveis e obrigações por texto livre.

## 2. Situação atual

- Backend: **Atendido** (`q` implementado em empresas, responsáveis e obrigações com validação de máx. 100 caracteres e `400 VALIDATION_ERROR`).
- Frontend: **Atendido** — Campo de busca em `CompanyListPage`, `ResponsibleListPage` e `ObligationListPage` com debounce de 400ms, botão limpar e empty state específico "Nenhum resultado para '<termo>'".

## 3. Escopo funcional

- [x] Parâmetro `q` em `GET /api/companies` (razão social, nome fantasia, CNPJ — aceitar com ou sem máscara).
- [x] Parâmetro `q` em `GET /api/responsibles` (nome, e-mail).
- [x] Parâmetro `q` em `GET /api/obligations` (título, descrição, razão social/nome fantasia da empresa, nome do responsável).
- [x] Busca case-insensitive, combinável com filtros e paginação existentes.
- [x] Flutter: campo de pesquisa no topo das três listagens com debounce (~400 ms) e botão limpar.
- [x] Estado vazio específico: "Nenhum resultado para '<termo>'".
- [x] Atualizar `docs/api.md`.

## 4. Regras e restrições

- `q` com espaços externos removidos; vazio = sem filtro.
- Limitar tamanho de `q` (ex.: 100 caracteres) → `400 VALIDATION_ERROR` se exceder.
- Consultas parametrizadas (sem concatenação de SQL).

## 5. Critérios de aceitação

- [x] Pesquisa retorna resultados corretos combinada com filtros.
- [x] Testes de repository/serviço/controller no backend e de widget no Flutter.
- [x] `check_docs.py` OK.

## 6. Cenários de teste

- **Sucesso:** `q=petro` encontra "Petróleo Brasileiro S.A.".
- **Validação:** `q` acima do limite → 400.
- **Falha de dependência:** erro de rede no Flutter → `ErrorStateView` com retry.
- **Regressão:** listagem sem `q` inalterada.

## 7. Dependências

- SPEC-006, SPEC-007, SPEC-008, SPEC-032.

## 8. Pendências

- Pesquisa por CNPJ parcial: confirmar se desejado.

## 9. Rastreabilidade

- `docs/api.md`.

