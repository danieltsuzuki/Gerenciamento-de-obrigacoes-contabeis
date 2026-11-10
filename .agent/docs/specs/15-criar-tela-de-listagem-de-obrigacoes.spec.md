# SPEC-015 — Criar tela de listagem de obrigações

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 15 |
| Card | [Criar tela de listagem de obrigações](https://trello.com/c/3wpXjbhp) |
| Status no Trello (10/11/2026) | Concluído |
| Versão da SPEC | 1.2 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Criar a tela inicial de obrigações com dados reais obtidos pela API e navegação para detalhes e edição.

## 2. Escopo funcional

- [x] Listar obrigações cadastradas.
- [x] Exibir título, descrição, empresa, responsável, status, quantidade de anexos e data de criação.
- [x] Exibir loading, erro e estado vazio.
- [x] Atualizar listagem após ações que alterem dados.
- [x] **Exibir detalhes ao clicar no card, mesmo deslogado**:
  - O toque no card da obrigação navega diretamente para a tela de detalhes da obrigação (`ObligationDetailPage`), permitindo consulta de dados por qualquer usuário (acesso anônimo).
- [x] **Ocultação do botão de edição quando deslogado**:
  - Na tela de detalhes da obrigação, o botão de edição **não deve ser visível** caso o usuário não esteja logado.
  - Se o usuário estiver autenticado, o botão de edição torna-se visível (para obrigações não concluídas).
- [x] **Direcionamento para edição via botão de editar**:
  - Ao clicar no botão de edição (no card da lista ou na tela de detalhes quando autenticado), direciona diretamente para o formulário de edição de obrigação (`ObligationFormPage`), protegido por `requireAuth`.

## 3. Regras de negócio e restrições

- Status deve ser distinguível visualmente (cores semânticas, bordas e ícones) e também por texto.
- A lista deve refletir os dados retornados pela API, sem inventar estado local.
- Falhas de carregamento devem permitir feedback adequado com retry (`ErrorStateView`).
- O vencimento (`dueDate`) deve destacar visualmente status de atraso (`isOverdue`).
- Acesso para leitura de detalhes é público/anônimo; modificação exige autenticação JWT.

## 4. Contratos e decisões técnicas

- Consumir `GET /api/obligations` via `ObligationRepository.getObligations` com paginação Spring Data e filtro opcional por `ObligationStatus`.
- Campos de exibição no card: `title`, `description`, `company.name`, `responsible.name`, `status` (com badge temático e ícone), `attachmentCount`, `createdAt` e `dueDate` formatados (`dd/MM/yyyy`).
- Barra superior de filtros rápidos com `ChoiceChip`s para filtragem dinâmica entre "Todas", "Pendentes", "Em Andamento" e "Concluídas".
- Seleção de item com suporte a callback `onObligationTap` e navegação para `AppRoutes.obligationDetails`.
- Ação de edição rápida com `IconButton(key: Key('obligation-edit-button-${id}'))` direcionando para `ObligationFormPage`.
- Atualização dinâmica após ações via `RefreshIndicator`, botão de recarregar e recarregamento automático após retorno de telas de detalhe/criação.

## 5. Critérios de aceitação

- [x] Dados são carregados da API.
- [x] Ao clicar no card, abre a tela de detalhes mesmo deslogado.
- [x] Botão de editar obrigação na tela de detalhes fica oculto caso o usuário não esteja logado.
- [x] Ao clicar no botão de edição, direciona para o formulário de edição.
- [x] Loading, erro e vazio são exibidos corretamente.
- [x] Após ações, os dados são atualizados.

## 6. Cenários de teste

- **Sucesso - Listagem:** listagem de obrigações com badges coloridos e cálculo de atraso.
- **Sucesso - Detalhes Anônimos:** toque no card abre tela de detalhes mesmo deslogado.
- **Segurança - Ocultação de Edição:** ausência do botão de editar em detalhes para anônimos.
- **Sucesso - Edição:** toque no botão de editar autenticado abre o formulário de edição.
- **Filtros e Atualização:** alternância de chips de status e pull-to-refresh.

## 7. Dependências

- `docs/api.md` (contratos `/api/obligations`).
- `frontend/lib/features/obligation/domain/entities/obligation.dart`.
- `frontend/lib/features/obligation/domain/repositories/obligation_repository.dart`.
- `frontend/lib/features/auth/presentation/widgets/auth_guard.dart`.

## 8. Pendências e pontos a confirmar

- *Resolvido:* O toque no card abre a tela de detalhes mesmo deslogado; a ação de edição só é apresentada a usuários autenticados.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/3wpXjbhp
- Documentação de referência: `docs/api.md`, `docs/status-implementacao.md`, `docs/CHANGELOG.md`.
