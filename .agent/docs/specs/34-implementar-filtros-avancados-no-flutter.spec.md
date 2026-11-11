# SPEC-034 — Implementar filtros avançados de obrigações no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Filtros** |

## 1. Objetivo

Expor na interface todos os filtros que a API já suporta, facilitando o acompanhamento das obrigações.

## 2. Situação atual

- Backend: **Atendido** — `companyId`, `responsibleId`, `status`, `dueFrom`, `dueTo` em `GET /api/obligations`; `active` em empresas/responsáveis. (`dueFrom`/`dueTo` não documentados — ver SPEC-029.)
- Frontend: **Parcial** — apenas chips de status (obrigações) e situação (empresas/responsáveis).

## 3. Escopo funcional

- [ ] Painel/folha de filtros na lista de obrigações: empresa, responsável, intervalo de prazo (`DateRangePicker`), status.
- [ ] Filtro rápido "Atrasadas" (prazo vencido e não concluída) — calculado no cliente ou via `dueTo=hoje-1` + status ≠ COMPLETED.
- [ ] Chips de filtros ativos com remoção individual e "Limpar filtros".
- [ ] Na tela de detalhes de empresa/responsável, atalho "Ver obrigações" aplicando o filtro correspondente.
- [ ] Persistir filtros durante a sessão de navegação.

## 4. Regras e restrições

- Regra 05: usar somente parâmetros documentados em `docs/api.md` (depende da SPEC-029 para `dueFrom`/`dueTo`).
- Filtros combináveis com pesquisa (SPEC-033) e paginação (SPEC-032).

## 5. Critérios de aceitação

- [ ] Cada filtro gera a query string correta.
- [ ] Testes de widget e de datasource cobrindo combinações.

## 6. Cenários de teste

- **Sucesso:** empresa X + status PENDING → somente itens correspondentes.
- **Validação:** `dueFrom` > `dueTo` bloqueado na UI.
- **Falha de dependência:** erro de rede mantém filtros e oferece retry.
- **Regressão:** chips de status existentes continuam funcionando.

## 7. Dependências

- SPEC-015, SPEC-029, SPEC-032, SPEC-033.

## 8. Pendências

- Status derivado "atrasada" consta em `docs/pendencias-e-perguntas-em-aberto.md`.

## 9. Rastreabilidade

- `docs/api.md`.

