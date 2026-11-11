# SPEC-032 — Implementar paginação nas listagens do Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída |
| Tipo | Diferencial (não obrigatório) — **Paginação** |

## 1. Objetivo

Completar o diferencial de paginação no frontend. O backend já pagina (`page`, `size`, `sort`) e o Flutter já possui `PageResponse`, mas as telas carregavam somente a primeira página.

## 2. Situação atual

- Backend: **Atendido** (`GET /api/companies`, `/api/responsibles`, `/api/obligations`).
- Frontend: **Atendido** — Paginação por controles Anterior/Próxima nas 3 listagens com contador `Página X de Y (N)`, reset de página ao filtrar/buscar e dropdowns de formulário com `size: 100`.

## 3. Escopo funcional

- [x] Controles "Anterior/Próxima" nas listas de obrigações, empresas e responsáveis.
- [x] Exibição de "Página X de Y (N registros)".
- [x] Reiniciar paginação ao trocar filtro, pesquisa ou após cadastro/edição.
- [x] Dropdowns do formulário de obrigação carregam todas as empresas/responsáveis ativos (`size: 100`), sem truncar em 20.
- [x] Ordenação selecionável na lista de obrigações (prazo, criação, título).

## 4. Regras e restrições

- Consumir somente contratos de `docs/api.md` (regra 05).
- Evitar requisições duplicadas concorrentes.

## 5. Critérios de aceitação

- [x] Com mais de 20 registros, todos são acessíveis pela UI através dos controles de página.
- [x] Erro ao carregar página seguinte exibe retry sem quebrar a aplicação.
- [x] Testes de widget cobrindo carga incremental, navegação entre páginas e fim da lista.

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

