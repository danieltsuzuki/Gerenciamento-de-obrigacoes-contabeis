# SPEC-016 — Criar listagem e formulário de empresas

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 16 |
| Card | [Criar listagem e formulário de empresas](https://trello.com/c/qiztV9zZ) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar interface Flutter para listar, cadastrar e editar empresas.

## 2. Escopo funcional

- [ ] Exibir listagem de empresas.
- [ ] Criar formulário de cadastro e edição.
- [ ] Campos: razão social, nome fantasia, CNPJ e situação.
- [ ] Validar campos obrigatórios e formato do CNPJ.
- [ ] Apresentar mensagens de validação junto aos campos.
- [ ] Exibir feedback de sucesso e erro.

## 3. Regras de negócio e restrições

- CNPJ deve ser validado no cliente para feedback e novamente pela API.
- CNPJ é único.
- Inativação é feita por situação; não existe exclusão física.
- Não permitir envio enquanto campos obrigatórios estiverem inválidos.

## 4. Contratos e decisões técnicas

- GET /api/companies; POST /api/companies; PUT /api/companies/{id}.
- Request: legalName, tradeName, cnpj, active.
- GET aceita active, page, size e sort.
- Erros da API devem ser apresentados de forma compreensível.

## 5. Critérios de aceitação

- [ ] Criar, editar e listar integrados à API.
- [ ] CNPJ inválido/duplicado mostra erro apropriado.
- [ ] Situação ativa/inativa é exibida e editável.
- [ ] Sucesso e falha geram feedback ao usuário.

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

- O card não exige busca, exclusão, confirmação de inativação nem paginação visual. Não incluir sem decisão.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/qiztV9zZ
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
