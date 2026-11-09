# SPEC-017 — Criar listagem e formulário de responsáveis

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 17 |
| Card | [Criar listagem e formulário de responsáveis](https://trello.com/c/ru5UKQDg) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar interface Flutter para listar, cadastrar e editar responsáveis.

## 2. Escopo funcional

- [ ] Exibir listagem de responsáveis.
- [ ] Criar formulário de cadastro e edição.
- [ ] Campos: nome, e-mail e situação.
- [ ] Validar obrigatoriedade e formato do e-mail.
- [ ] Apresentar erros junto aos campos.
- [ ] Exibir feedback de sucesso e erro.

## 3. Regras de negócio e restrições

- E-mail deve ser válido e único.
- Responsáveis inativos não podem ser atribuídos a novas obrigações.
- Inativação lógica por active=false; sem exclusão física.
- Nunca exibir senha/hash em telas ou responses.

## 4. Contratos e decisões técnicas

- GET /api/responsibles; POST /api/responsibles; PUT /api/responsibles/{id}.
- Campos: name, email, active; o contrato de criação também possui password conforme docs/api.md.
- GET aceita active, page, size e sort.

## 5. Critérios de aceitação

- [ ] Criar, editar e listar integrados à API.
- [ ] E-mail inválido/duplicado é comunicado.
- [ ] Situação é exibida e atualizada.
- [ ] Erros e sucessos são apresentados claramente.

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

- O card não especifica como a senha será solicitada no cadastro/edição. A API de criação documenta password, mas o PUT não recebe senha. Definir experiência sem expor/editar credenciais indevidamente.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/ru5UKQDg
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
