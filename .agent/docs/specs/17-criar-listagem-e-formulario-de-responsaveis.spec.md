# SPEC-017 — Criar listagem, formulário e detalhes de responsáveis

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 17 |
| Card | [Criar listagem e formulário de responsáveis](https://trello.com/c/ru5UKQDg) |
| Status no Trello (10/11/2026) | Concluído |
| Versão da SPEC | 1.3 |
| Situação da especificação | Concluída e testada |

## 1. Objetivo

Implementar interface Flutter para listar, detalhar, cadastrar e editar responsáveis contábeis, integrada aos contratos REST da API (`GET /api/responsibles`, `GET /api/responsibles/{id}`, `POST /api/responsibles`, `PUT /api/responsibles/{id}`).

## 2. Escopo funcional

- [x] Exibir listagem paginada de responsáveis com avatar inicial, nome, e-mail e badge de status.
- [x] Filtros rápidos por situação cadastral: chips `Todos`, `Ativos` e `Inativos`.
- [x] **Exibir detalhes de responsáveis (`ResponsibleDetailPage`)**:
  - Exibe avatar de destaque, nome, e-mail, identificador do sistema (`#ID`) e situação operacional explicativa (se pode ou não receber novas obrigações).
  - Consulta detalhada por ID (`GET /api/responsibles/{id}`), aberta para consulta anônima.
  - Ação para navegar ao formulário de edição com recarregamento dos dados ao retornar.
- [x] **Ocultação de ações de edição para usuários anônimos na tela de detalhes**:
  - Os botões de editar responsável (tanto o ícone na AppBar quanto o botão de ação principal da tela) **não devem ser visíveis** caso o usuário não esteja logado.
  - Ao autenticar, os botões tornam-se visíveis reativamente para permitir a edição.
- [x] **Separação de ações na listagem**:
  - Toque no card/ListTile: abre a tela de detalhes do responsável (`ResponsibleDetailPage`), permitindo consulta rápida sem exigir autenticação.
  - Toque no ícone de editar (`IconButton` de edição no card): aciona diretamente o fluxo de edição (`ResponsibleFormPage`), protegido por `requireAuth`.
- [x] Formulário de cadastro de novo responsável com campos: Nome completo, E-mail corporativo, Senha inicial (com alternância de visibilidade) e Situação cadastral (`active`).
- [x] Formulário de edição de responsável existente com campos pré-preenchidos: Nome completo, E-mail corporativo e Situação cadastral (`active` para inativação lógica).
- [x] Omissão segura de credenciais em modo de edição: a senha nunca é exposta nem editada pelo formulário de responsável.
- [x] Validação inline: nome obrigatório (máx. 255), formato de e-mail corporativo válido via regex (máx. 255), senha inicial obrigatória no cadastro (mín. 6, máx. 100 caracteres).
- [x] Tratamento de erros de domínio: captura de `409 DUPLICATE_EMAIL` com feedback explicativo (`RN-003`), erros de validação e falhas de conexão.
- [x] Exibição de feedback visual com SnackBar de sucesso e recarregamento automático da listagem.
- [x] Proteção de rotas e mutações via `requireAuth` / `AppRoutes`.

## 3. Regras de negócio e restrições

- **RN-003**: E-mail do responsável deve ser corporativo, válido e único no sistema. Conflito `409 DUPLICATE_EMAIL` tratado.
- **RN-005**: Responsáveis inativos não podem ser atribuídos a novas obrigações; a situação cadastral é facilmente alternada pelo switch.
- Inativação lógica por `active=false`; sem exclusão física no banco de dados.
- Segurança de credenciais: a senha é enviada via payload HTTPS seguro no cadastro com Bcrypt no backend e nunca exibida em telas ou listagens.

## 4. Contratos e decisões técnicas

- `GET /api/responsibles`: listagem com suporte ao query param `active` (`true`/`false`/`null`).
- `GET /api/responsibles/{id}`: consulta detalhada de responsável por ID (aberto para acesso anônimo).
- `POST /api/responsibles`: criação com payload `{ name, email, password, active }`.
- `PUT /api/responsibles/{id}`: atualização com payload `{ name, email, active }`.
- Rotas nomeadas:
  - `AppRoutes.responsibles` (`/responsibles`)
  - `AppRoutes.responsibleDetails` (`/responsibles/details`)
  - `AppRoutes.responsibleCreate` (`/responsibles/create`)
  - `AppRoutes.responsibleEdit` (`/responsibles/edit`)

## 5. Critérios de aceitação

- [x] Criar, editar, detalhar e listar responsáveis totalmente integrados à API e ao repositório Flutter.
- [x] Toque no card abre a tela de detalhes; toque no botão de editar abre o formulário de edição pré-preenchido.
- [x] Botões de edição (no card da listagem e na tela de detalhes) e botão FAB de criação ficam estritamente ocultos para usuários não logados.
- [x] No formulário de cadastro, o switch de situação cadastral é omitido e o responsável é criado sempre como ativo (`active: true`).
- [x] No formulário de edição, a situação cadastral (Ativo/Inativo) é exibida e permite inativação lógica via switch.
- [x] Formato inválido de e-mail e e-mail duplicado são devidamente comunicados ao usuário.
- [x] Feedbacks de sucesso (SnackBar verde) e erro (banner e campos com erro) claros.
- [x] Cobertura automatizada por testes de unidade e widgets (`responsible_detail_page_test.dart`, `responsible_form_page_test.dart` e `responsible_list_page_test.dart`).

## 6. Cenários de teste

- **Sucesso - Listagem:** renderização de responsáveis com avatar, nome, e-mail e status chip.
- **Sucesso - Detalhes:** navegação para a tela de detalhes ao clicar no card, exibindo ID, nome, e-mail e status.
- **Segurança - Ocultação:** ausência dos botões de edição e criação para usuários não autenticados.
- **Formulário de Cadastro:** omissão do switch de situação cadastral, criando responsável ativo por padrão.
- **Sucesso - Edição:** abertura pré-preenchida ao clicar no ícone de editar (autenticado), inativação lógica via switch e envio de `UpdateResponsibleRequest`.
- **Validação:** bloqueio de submissão com campos vazios, e-mail inválido ou senha menor que 6 caracteres.
- **Conflito de negócio:** tratamento visual de `409 DUPLICATE_EMAIL`.
- **Autenticação:** proteção com `requireAuth` nas ações de criação e edição.

## 7. Dependências

- `docs/api.md` (contratos `/api/responsibles`).
- `frontend/lib/features/responsible/domain/entities/responsible.dart`.
- `frontend/lib/features/responsible/domain/repositories/responsible_repository.dart`.
- `frontend/lib/features/auth/presentation/widgets/auth_guard.dart`.

## 8. Pendências e pontos a confirmar

- *Resolvido:* Ações separadas na listagem: o card abre os detalhes e o ícone abre o formulário de edição. No cadastro, a senha é solicitada (mín. 6 caracteres) com obscure toggle; na edição, a senha não é exposta nem editada.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/ru5UKQDg
- Documentação de referência: `docs/api.md`, `docs/status-implementacao.md`, `docs/CHANGELOG.md`.
