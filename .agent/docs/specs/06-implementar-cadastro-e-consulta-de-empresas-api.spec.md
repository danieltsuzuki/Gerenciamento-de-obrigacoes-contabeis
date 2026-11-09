# SPEC-006 — Implementar cadastro e consulta de empresas (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 6 |
| Card | [Implementar cadastro e consulta de empresas (API)](https://trello.com/c/sdG0b0yu) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — endpoints REST, validações, segurança JWT e testes de integração implementados |

## 1. Objetivo

Disponibilizar API REST para criar, consultar, listar, atualizar e inativar empresas.

## 2. Escopo funcional

- [x] POST /api/companies cria empresa (`CompanyController#create`).
- [x] GET /api/companies lista empresas com paginação e filtro active opcional (`CompanyController#list`).
- [x] GET /api/companies/{id} consulta por ID (`CompanyController#getById`).
- [x] PUT /api/companies/{id} atualiza dados e situação (`CompanyController#update`).
- [x] Validar legalName, tradeName, CNPJ e active (`CreateCompanyRequest`, `UpdateCompanyRequest`, `ValidCnpj`).

## 3. Regras de negócio e restrições

- CNPJ é normalizado para somente dígitos e validado por DVs (RN-001).
- CNPJ deve ser único (RN-002).
- Não existe exclusão física; inativação por `active=false` (RN-004, ADR-0001).
- Operações POST e PUT exigem JWT; GET é anônimo, conforme `docs/api.md` e `docs/arquitetura.md`.

## 4. Contratos e decisões técnicas

- POST Request: legalName obrigatório, tradeName opcional, cnpj obrigatório, active opcional (padrão true).
- PUT Request: legalName, tradeName, cnpj e active.
- GET list: active opcional; page=0, size=20, sort=id,asc (Spring Data Pageable).
- Respostas: 201, 200, 400, 401, 404, 409/422 DUPLICATE_CNPJ.

## 5. Critérios de aceitação

- [x] Criar, listar, consultar e atualizar empresa funcionam.
- [x] CNPJ inválido ou duplicado é rejeitado.
- [x] Hash/segredos não são expostos.
- [x] Testes unitários e integração cobrem sucesso e erros.

## 6. Cenários de teste

- **Sucesso:** ciclo completo de criação, consulta, atualização e listagem (`CompanyApiIntegrationTest#testCompanyApiLifecycle`).
- **Validação:** rejeição de CNPJ com formato incorreto ou DVs inválidos (`CnpjTest`, `CompanyControllerTest`).
- **Falha de dependência:** rejeição de duplicidade de CNPJ (`CompanyServiceTest`, `DatabaseMigrationIntegrationTest`).
- **Regressão:** bloqueio de requisições `DELETE` com `405 Method Not Allowed`.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- Nenhum. Filtros, paginação, validação e segurança implementados e documentados.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/sdG0b0yu
- Documentação de referência: `docs/api.md`, `docs/arquitetura.md`, `docs/index.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
