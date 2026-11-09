# SPEC-020 — Implementar fluxo de alteração de status no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 20 |
| Card | [Implementar fluxo de alteração de status no Flutter](https://trello.com/c/gChKmU1v) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar na interface a progressão de status da obrigação de acordo com a máquina de estados do backend.

## 2. Escopo funcional

- [ ] PENDING: apresentar ação iniciar e solicitar IN_PROGRESS.
- [ ] IN_PROGRESS: apresentar ação concluir e solicitar COMPLETED.
- [ ] COMPLETED: não apresentar ação de alteração.
- [ ] Solicitar confirmação quando apropriado.
- [ ] Atualizar estado com a resposta do servidor.
- [ ] Tratar conflito/regra inválida.

## 3. Regras de negócio e restrições

- Não oferecer reabertura.
- Não oferecer conclusão duplicada.
- Não permitir saltos/regressões na UI.
- Backend é a autoridade final da transição.

## 4. Contratos e decisões técnicas

- PATCH /api/obligations/{id}/status com {status}.
- Autenticação JWT obrigatória.
- 422 INVALID_STATUS_TRANSITION deve ser tratado.

## 5. Critérios de aceitação

- [ ] Cada status apresenta apenas a próxima ação permitida.
- [ ] Ação chama API e atualiza tela somente após sucesso.
- [ ] Erros do servidor são comunicados sem corromper estado local.

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

- O card não define perfil autorizado a alterar status. A pendência do projeto pergunta se somente o responsável pode avançar; até decisão, não assumir autorização por papel.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/gChKmU1v
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
