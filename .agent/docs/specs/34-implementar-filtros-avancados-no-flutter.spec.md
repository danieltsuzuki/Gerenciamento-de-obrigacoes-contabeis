# SPEC-034 — Implementar filtros avançados de obrigações no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída |
| Tipo | Diferencial (não obrigatório) — **Filtros** |

## 1. Objetivo

Expor na interface todos os filtros que a API já suporta, facilitando o acompanhamento das obrigações.

## 2. Situação atual

- Backend: **Atendido** — `companyId`, `responsibleId`, `status`, `dueFrom`, `dueTo`, `q` em `GET /api/obligations`; `active` em empresas/responsáveis.
- Frontend: **Atendido** — BottomSheet de filtros avançados (empresa, responsável, `DateRangePicker`), chip rápido "Apenas Atrasadas", chips de filtros ativos com remoção individual e botão "Limpar todos", atalhos "Ver Obrigações desta Empresa / deste Responsável" nas telas de detalhes e suporte a inicialização via argumentos de rota.

## 3. Escopo funcional

- [x] Painel/folha de filtros na lista de obrigações: empresa, responsável, intervalo de prazo (`DateRangePicker`), status.
- [x] Filtro rápido "Atrasadas" (prazo vencido e não concluída) via `dueTo=ontem`.
- [x] Chips de filtros ativos com remoção individual e "Limpar todos".
- [x] Na tela de detalhes de empresa/responsável, atalho "Ver Obrigações" aplicando o filtro correspondente.
- [x] Suporte a argumentos de rota para aplicar filtros ao abrir a tela.

## 4. Regras e restrições

- Regra 05: usar somente parâmetros documentados em `docs/api.md`.
- Filtros combináveis com pesquisa (SPEC-033) e paginação (SPEC-032).

## 5. Critérios de aceitação

- [x] Cada filtro gera a query string correta no repositório/datasource.
- [x] Testes de widget e de datasource cobrindo combinações.

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

