# SPEC-019 — Criar tela de detalhes da obrigação

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 19 |
| Card | [Criar tela de detalhes da obrigação](https://trello.com/c/82pKQj1o) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Exibir os dados completos de uma obrigação e disponibilizar ações compatíveis com seu estado atual.

## 2. Escopo funcional

- [ ] Exibir título e descrição.
- [ ] Exibir empresa e responsável.
- [ ] Exibir status, data de criação e anexos.
- [ ] Disponibilizar ações compatíveis com status atual.
- [ ] Carregar dados reais da API.
- [ ] Exibir loading e erro.
- [ ] Atualizar a tela após ações.

## 3. Regras de negócio e restrições

- Ações disponíveis devem respeitar máquina de estados.
- COMPLETED não permite alteração de status.
- Anexos devem ser exibidos vinculados à obrigação.
- A tela não deve simular sucesso antes da resposta do servidor.

## 4. Contratos e decisões técnicas

- GET /api/obligations/{id} para detalhes.
- GET /api/obligations/{id}/attachments para metadados.
- Dados de detalhe incluem completedAt quando houver, além de dados relacionados.

## 5. Critérios de aceitação

- [ ] Tela exibe dados reais e estados loading/erro.
- [ ] Ações são coerentes com status.
- [ ] Após ação, detalhes/status/anexos são atualizados.
- [ ] Item pode ser aberto a partir da listagem.

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

- O card não define edição de dados, remoção/substituição de anexos, permissões por perfil nem visualização inline de arquivos. Respeitar pendências documentadas.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/82pKQj1o
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
