# SPEC-008 — Implementar cadastro e consulta de obrigações (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 8 |
| Card | [Implementar cadastro e consulta de obrigações (API)](https://trello.com/c/qso1Id1r) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Disponibilizar API REST para criar, listar, consultar e atualizar obrigações.

## 2. Escopo funcional

- [ ] POST /api/obligations cria obrigação.
- [ ] GET /api/obligations lista com paginação e filtros companyId, responsibleId e status.
- [ ] GET /api/obligations/{id} retorna detalhes.
- [ ] PUT /api/obligations/{id} atualiza dados e permite reatribuição conforme regras.
- [ ] Retornar resumo de empresa/responsável, status, attachmentCount e createdAt na listagem.

## 3. Regras de negócio e restrições

- No cadastro, empresa e responsável devem existir e estar ativos (RN-006).
- Status inicial é definido no servidor como PENDING.
- createdAt é automático.
- Reatribuições devem validar novo vínculo ativo.
- Operações POST/PUT exigem JWT; GET é anônimo.

## 4. Contratos e decisões técnicas

- POST body: companyId, responsibleId, title, description opcional, dueDate.
- GET filters: companyId, responsibleId, status; page=0, size=20, sort=dueDate,asc.
- PUT body documentado inclui companyId, responsibleId, title, description, dueDate e status opcional.
- GET detalhe inclui completedAt quando houver.
- HTTP: 201/200, 400, 401, 404, 422 para inativos/transição inválida.

## 5. Critérios de aceitação

- [ ] Obrigação é criada em PENDING sem aceitar status inicial do cliente.
- [ ] Empresa/responsável inexistente ou inativo são tratados corretamente.
- [ ] Listagem inclui campos de apresentação e contagem de anexos.
- [ ] Testes de serviço, controller e integração aprovados.

## 6. Cenários de teste

- **Sucesso:** validar o fluxo principal descrito nesta SPEC.
- **Validação:** rejeitar dados obrigatórios ausentes ou inválidos.
- **Falha de dependência:** apresentar erro apropriado quando API, banco ou storage não estiver disponível, quando aplicável.
- **Regressão:** garantir que a funcionalidade não viole regras existentes do domínio.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`, quando aplicável.
- Modelo de dados em `docs/modelo-de-dados.md`, quando aplicável.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- Há duas formas documentadas de mudar status: PUT /api/obligations/{id} com status opcional e PATCH /api/obligations/{id}/status. A UI deve preferir o PATCH explícito para transição de estado.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/qso1Id1r
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
