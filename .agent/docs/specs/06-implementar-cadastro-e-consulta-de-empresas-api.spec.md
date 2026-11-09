# SPEC-006 — Implementar cadastro e consulta de empresas (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 6 |
| Card | [Implementar cadastro e consulta de empresas (API)](https://trello.com/c/sdG0b0yu) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Disponibilizar API REST para criar, consultar, listar, atualizar e inativar empresas.

## 2. Escopo funcional

- [ ] POST /api/companies cria empresa.
- [ ] GET /api/companies lista empresas com paginação e filtro active opcional.
- [ ] GET /api/companies/{id} consulta por ID.
- [ ] PUT /api/companies/{id} atualiza dados e situação.
- [ ] Validar legalName, tradeName, CNPJ e active.

## 3. Regras de negócio e restrições

- CNPJ é normalizado para somente dígitos e validado por DVs.
- CNPJ deve ser único.
- Não existe exclusão física; inativação por `active=false`.
- Operações POST e PUT exigem JWT; GET é anônimo, conforme docs/api.md.

## 4. Contratos e decisões técnicas

- POST Request: legalName obrigatório, tradeName opcional, cnpj obrigatório, active opcional (padrão true).
- PUT Request: legalName, tradeName, cnpj e active.
- GET list: active opcional; page=0, size=20, sort=id,asc.
- Respostas: 201, 200, 400, 401, 404, 409 DUPLICATE_CNPJ.

## 5. Critérios de aceitação

- [ ] Criar, listar, consultar e atualizar empresa funcionam.
- [ ] CNPJ inválido ou duplicado é rejeitado.
- [ ] Hash/segredos não são expostos.
- [ ] Testes unitários e integração cobrem sucesso e erros.

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

- O card menciona filtros/paginação como melhoria; docs/api.md já descreve paginação e filtro active. O contrato documentado é a referência atual.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/sdG0b0yu
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
