# SPEC-016 — Criar listagem, detalhes e formulário de empresas

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 16 |
| Card | [Criar listagem e formulário de empresas](https://trello.com/c/qiztV9zZ) |
| Status no Trello (10/11/2026) | Concluído |
| Versão da SPEC | 1.2 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Implementar interface Flutter para listar, detalhar, cadastrar e editar empresas clientes.

## 2. Escopo funcional

- [x] Exibir listagem de empresas com razão social, nome fantasia, CNPJ formatado e status.
- [x] **Exibir detalhes da empresa (`CompanyDetailPage`)**:
  - Exibe avatar temático, razão social, nome fantasia, CNPJ formatado (`XX.XXX.XXX/XXXX-XX`), identificador do sistema (`#ID`) e situação operacional explicativa.
  - Acesso anônimo permitido (`GET /api/companies/{id}`).
- [x] **Ocultação de ações de edição para usuários anônimos**:
  - Na tela de detalhes, os botões de edição de empresa (AppBar e ação principal) **não devem ser visíveis caso o usuário não esteja logado**.
  - Ao autenticar, os botões tornam-se visíveis reativamente para permitir a edição.
- [x] **Separação de ações na listagem**:
  - Toque no card/ListTile: abre a tela de detalhes (`CompanyDetailPage`), permitindo visualização rápida mesmo deslogado.
  - Toque no ícone de edição (`company-edit-button-${id}`): direciona diretamente para o formulário de edição (`CompanyFormPage`), protegido por `requireAuth`.
- [x] Criar formulário de cadastro e edição (`CompanyFormPage`).
- [x] Campos: razão social, nome fantasia, CNPJ e situação cadastral.
- [x] Validar campos obrigatórios e formato do CNPJ com cálculo dos dígitos verificadores (RN-001).
- [x] Apresentar mensagens de validação junto aos campos.
- [x] Exibir feedback de sucesso e erro com tratamento semântico de duplicidade (`409 DUPLICATE_CNPJ` - RN-002).

## 3. Regras de negócio e restrições

- CNPJ validado no cliente através de algoritmo com cálculo dos dois dígitos verificadores (`CnpjValidator` - RN-001) e revalidado pela API.
- CNPJ é único: erros `409 DUPLICATE_CNPJ` são apresentados de forma clara (RN-002).
- Inativação é feita por situação cadastral (`active: false`); não existe exclusão física (RN-004).
- Não permitir envio enquanto campos obrigatórios ou formato de CNPJ estiverem inválidos.
- Consulta de detalhes aberta para acesso anônimo; edição exige autenticação JWT (`requireAuth`).

## 4. Contratos e decisões técnicas

- `GET /api/companies` via `CompanyRepository.getCompanies` com filtro opcional por `active` (Todas, Ativas, Inativas).
- `GET /api/companies/{id}` via `CompanyRepository.getCompanyById`.
- `POST /api/companies` via `CompanyRepository.createCompany` com `CreateCompanyRequest(legalName, tradeName, cnpj, active)`.
- `PUT /api/companies/{id}` via `CompanyRepository.updateCompany` com `UpdateCompanyRequest(legalName, tradeName, cnpj, active)`.
- Rotas nomeadas:
  - `AppRoutes.companies` (`/companies`)
  - `AppRoutes.companyDetails` (`/companies/details`)
  - `AppRoutes.companyCreate` (`/companies/create`)
  - `AppRoutes.companyEdit` (`/companies/edit`)

## 5. Critérios de aceitação

- [x] Criar, editar, detalhar e listar integrados à API.
- [x] Ao clicar no card, exibe a tela de detalhes mesmo deslogado.
- [x] Botões de edição não são exibidos na tela de detalhes caso o usuário não esteja logado.
- [x] Ao clicar no botão de edição (no card ou na tela de detalhes autenticado), direciona para o formulário de edição.
- [x] CNPJ inválido/duplicado mostra erro apropriado.
- [x] Situação ativa/inativa é exibida e editável.
- [x] Sucesso e falha geram feedback ao usuário.

## 6. Cenários de teste

- **Sucesso - Listagem:** listagem de empresas com nome, CNPJ formatado e chips de status.
- **Sucesso - Detalhes:** visualização anônima dos dados cadastrais completos.
- **Segurança - Ocultação:** ausência dos botões de edição na página de detalhes quando desautenticado.
- **Sucesso - Edição:** abertura pré-preenchida ao clicar no ícone de editar (autenticado).
- **Validação:** validação de CNPJ, campos obrigatórios e tratamento de `409 DUPLICATE_CNPJ`.

## 7. Dependências

- `docs/api.md` (contratos `/api/companies`).
- `frontend/lib/features/company/domain/entities/company.dart`.
- `frontend/lib/features/company/domain/repositories/company_repository.dart`.
- `frontend/lib/features/auth/presentation/widgets/auth_guard.dart`.

## 8. Pendências e pontos a confirmar

- *Resolvido:* Ações separadas na listagem: o toque no card abre detalhes e o ícone abre o formulário de edição. Botão de edição oculto para anônimos na tela de detalhes.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/qiztV9zZ
- Documentação de referência: `docs/api.md`, `docs/status-implementacao.md`, `docs/CHANGELOG.md`.
