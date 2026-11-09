# SPEC-008 — Implementar cadastro e consulta de obrigações (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 8 |
| Card | [Implementar cadastro e consulta de obrigações (API)](https://trello.com/c/qso1Id1r) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — endpoints REST, filtros, contagem de anexos, RN-006 e testes de integração implementados |

## 1. Objetivo

Disponibilizar API REST para criar, listar, consultar e atualizar obrigações.

## 2. Escopo funcional

- [x] POST /api/obligations cria obrigação (`ObligationController#create`).
- [x] GET /api/obligations lista com paginação e filtros companyId, responsibleId e status (`ObligationController#list`).
- [x] GET /api/obligations/{id} retorna detalhes (`ObligationController#getById`).
- [x] PUT /api/obligations/{id} atualiza dados e permite reatribuição conforme regras (`ObligationController#update`).
- [x] Retornar resumo de empresa/responsável, status, attachmentCount e createdAt na listagem (`ObligationListItemResponse`).

## 3. Regras de negócio e restrições

- No cadastro, empresa e responsável devem existir e estar ativos (RN-006).
- Status inicial é definido no servidor como PENDING (RN-008).
- createdAt é automático.
- Reatribuições devem validar novo vínculo ativo.
- Operações POST/PUT exigem JWT; GET é anônimo (`docs/api.md`).

## 4. Contratos e decisões técnicas

- POST body: companyId, responsibleId, title, description opcional, dueDate.
- GET filters: companyId, responsibleId, status, dueFrom, dueTo; page=0, size=20, sort=dueDate,asc (Spring Data Pageable).
- PUT body: companyId, responsibleId, title, description, dueDate e status opcional.
- GET detalhe inclui completedAt e attachmentCount.
- HTTP: 201/200, 400, 401, 404, 422 para inativos/transição inválida.

## 5. Critérios de aceitação

- [x] Obrigação é criada em PENDING sem aceitar status inicial do cliente.
- [x] Empresa/responsável inexistente ou inativo são tratados corretamente.
- [x] Listagem inclui campos de apresentação e contagem de anexos.
- [x] Testes de serviço, controller e integração aprovados.

## 6. Cenários de teste

- **Sucesso:** ciclo completo de criação, consulta, atualização e listagem com contagem de anexos (`ObligationApiIntegrationTest`).
- **Validação:** validação de campos obrigatórios ausentes (`ObligationControllerTest`).
- **Falha de dependência:** rejeição de criação para empresa ou responsável inativo (422) ou inexistente (404) (`ObligationServiceTest`).
- **Regressão:** bloqueio de requisições `DELETE` com `405 Method Not Allowed`.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- Transição de status preferencialmente realizada via PATCH `/api/obligations/{id}/status` dedicado (SPEC-009).

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/qso1Id1r
- Documentação de referência: `docs/api.md`, `docs/arquitetura.md`, `docs/index.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
