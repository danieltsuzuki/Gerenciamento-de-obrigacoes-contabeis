# SPEC-033 — Implementar pesquisa textual (API e Flutter)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Pesquisa** |

## 1. Objetivo

Permitir localizar rapidamente empresas, responsáveis e obrigações por texto livre.

## 2. Situação atual

- **Ausente** no backend e no frontend.

## 3. Escopo funcional

- [ ] Parâmetro `q` em `GET /api/companies` (razão social, nome fantasia, CNPJ — aceitar com ou sem máscara).
- [ ] Parâmetro `q` em `GET /api/responsibles` (nome, e-mail).
- [ ] Parâmetro `q` em `GET /api/obligations` (título, descrição, razão social/nome fantasia da empresa, nome do responsável).
- [ ] Busca case-insensitive, combinável com filtros e paginação existentes.
- [ ] Flutter: campo de pesquisa (`SearchBar`) no topo das três listagens com debounce (~400 ms) e botão limpar.
- [ ] Estado vazio específico: "Nenhum resultado para '<termo>'".
- [ ] Atualizar `docs/api.md`.

## 4. Regras e restrições

- `q` com espaços externos removidos; vazio = sem filtro.
- Limitar tamanho de `q` (ex.: 100 caracteres) → `400 VALIDATION_ERROR` se exceder.
- Consultas parametrizadas (sem concatenação de SQL).
- Avaliar índices no MySQL via nova migration Flyway, se necessário.

## 5. Critérios de aceitação

- [ ] Pesquisa retorna resultados corretos combinada com filtros.
- [ ] Testes de repository/serviço/controller no backend e de widget no Flutter.
- [ ] `check_docs.py` OK.

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

