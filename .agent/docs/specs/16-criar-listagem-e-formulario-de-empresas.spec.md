# SPEC-016 — Criar listagem e formulário de empresas

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 16 |
| Card | [Criar listagem e formulário de empresas](https://trello.com/c/qiztV9zZ) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Implementar interface Flutter para listar, cadastrar e editar empresas.

## 2. Escopo funcional

- [x] Exibir listagem de empresas.
- [x] Criar formulário de cadastro e edição.
- [x] Campos: razão social, nome fantasia, CNPJ e situação.
- [x] Validar campos obrigatórios e formato do CNPJ.
- [x] Apresentar mensagens de validação junto aos campos.
- [x] Exibir feedback de sucesso e erro.

## 3. Regras de negócio e restrições

- CNPJ validado no cliente através de algoritmo com cálculo dos dois dígitos verificadores (`CnpjValidator` - RN-001) e revalidado pela API.
- CNPJ é único: erros `409 DUPLICATE_CNPJ` são apresentados de forma clara (RN-002).
- Inativação é feita por situação cadastral (`active: false`); não existe exclusão física (RN-004).
- Não permitir envio enquanto campos obrigatórios ou formato de CNPJ estiverem inválidos.

## 4. Contratos e decisões técnicas

- `GET /api/companies` via `CompanyRepository.getCompanies` com filtro opcional por `active` (Todas, Ativas, Inativas).
- `POST /api/companies` via `CompanyRepository.createCompany` com `CreateCompanyRequest(legalName, tradeName, cnpj, active)`.
- `PUT /api/companies/{id}` via `CompanyRepository.updateCompany` com `UpdateCompanyRequest(legalName, tradeName, cnpj, active)`.
- Validador `CnpjValidator` com stripping de máscara, validação de 14 dígitos, rejeição de repetidos, cálculo de DV1/DV2 e formatação visual `XX.XXX.XXX/XXXX-XX`.
- `CompanyFormPage` com suporte dual a cadastro e edição, validação síncrona inline em `TextFormField`s, bloqueio de submissão duplicada com indicador de progresso e tratamento semântico de erros de duplicidade e validação.
- `CompanyListPage` com `ChoiceChip`s de filtragem, formatação de dados, chips de situação e navegação para cadastro e edição.

## 5. Critérios de aceitação

- [x] Criar, editar e listar integrados à API.
- [x] CNPJ inválido/duplicado mostra erro apropriado.
- [x] Situação ativa/inativa é exibida e editável.
- [x] Sucesso e falha geram feedback ao usuário.

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
