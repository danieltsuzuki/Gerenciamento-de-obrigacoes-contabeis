# SPEC-032 — Implementar paginação nas listagens do Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Paginação** |

## 1. Objetivo

Completar o diferencial de paginação no frontend. O backend já pagina (`page`, `size`, `sort`) e o Flutter já possui `PageResponse`, mas as telas carregam somente a primeira página.

## 2. Situação atual

- Backend: **Atendido** (`GET /api/companies`, `/api/responsibles`, `/api/obligations`).
- Frontend: **Parcial** — `PageResponse` existe; listas não carregam páginas seguintes.

## 3. Escopo funcional

- [ ] Rolagem infinita (carregar próxima página ao se aproximar do fim) ou controles "Anterior/Próxima" nas listas de obrigações, empresas e responsáveis.
- [ ] Indicador de carregamento no rodapé e exibição de "x de N registros".
- [ ] Reiniciar paginação ao trocar filtro, pesquisa ou após cadastro/edição.
- [ ] Dropdowns do formulário de obrigação carregam todas as empresas/responsáveis ativos (paginação ou `size` adequado), sem truncar em 20.
- [ ] Ordenação selecionável na lista de obrigações (prazo, criação, título).

## 4. Regras e restrições

- Consumir somente contratos de `docs/api.md` (regra 05).
- Evitar requisições duplicadas concorrentes.

## 5. Critérios de aceitação

- [ ] Com mais de 20 registros, todos são acessíveis pela UI.
- [ ] Erro ao carregar página seguinte exibe retry sem perder os itens já carregados.
- [ ] Testes de widget cobrindo carga incremental, fim da lista e erro.

## 6. Cenários de teste

- **Sucesso:** 45 itens → 3 páginas carregadas.
- **Validação:** `last=true` interrompe novas requisições.
- **Falha de dependência:** erro 500 na página 2 → retry.
- **Regressão:** filtros por status/situação continuam funcionando.

## 7. Dependências

- SPEC-014, SPEC-015, SPEC-016, SPEC-017, SPEC-018.

## 8. Pendências

- Escolher rolagem infinita vs. paginação numerada.

## 9. Rastreabilidade

- `docs/api.md` (parâmetros de paginação).

