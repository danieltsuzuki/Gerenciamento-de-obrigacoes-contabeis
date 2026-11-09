# SPEC-009 — Implementar máquina de estados da obrigação

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 9 |
| Card | [Implementar máquina de estados da obrigação](https://trello.com/c/YDrtyWN1) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar no domínio a operação explícita e protegida para transição do status de uma obrigação.

## 2. Escopo funcional

- [ ] Implementar PATCH /api/obligations/{id}/status.
- [ ] Permitir PENDING → IN_PROGRESS.
- [ ] Permitir IN_PROGRESS → COMPLETED.
- [ ] Bloquear saltos, regressões, transição para o mesmo status e qualquer transição a partir de COMPLETED.
- [ ] Preencher completedAt ao concluir.

## 3. Regras de negócio e restrições

- COMPLETED é terminal.
- Transições inválidas não podem alterar status nem completedAt.
- Domínio deve proteger a regra independentemente da camada HTTP.
- A transição não é idempotente: status igual ao atual é rejeitado.

## 4. Contratos e decisões técnicas

- Request: { status: IN_PROGRESS | COMPLETED }.
- Autenticação JWT obrigatória.
- Respostas documentadas: 200, 400, 401, 404 e 422 INVALID_STATUS_TRANSITION.

## 5. Critérios de aceitação

- [ ] Todos os caminhos válidos atualizam estado.
- [ ] Saltos, regressões, repetição e reabertura são rejeitados.
- [ ] completedAt é preenchido somente ao concluir.
- [ ] Testes unitários de domínio, serviço, controller e integração cobrem casos positivos/negativos.

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

- A documentação de API também permite status opcional em PUT /api/obligations/{id}; manter o PATCH como contrato dedicado e não duplicar lógica de domínio.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/YDrtyWN1
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
