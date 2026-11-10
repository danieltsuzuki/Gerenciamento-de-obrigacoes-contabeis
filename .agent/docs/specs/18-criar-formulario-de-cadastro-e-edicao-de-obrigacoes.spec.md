# SPEC-018 — Criar formulário de cadastro e edição de obrigações

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 18 |
| Card | [Criar formulário de cadastro e edição de obrigações](https://trello.com/c/DlkBtqch) |
| Status no Trello (10/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída e testada |

## 1. Objetivo

Implementar interface Flutter unificada (`ObligationFormPage`) para cadastro e edição de obrigações fiscais/contábeis, integrada aos contratos REST da API (`POST /api/obligations` e `PUT /api/obligations/{id}`).

## 2. Escopo funcional

- [x] Formulário de cadastro de nova obrigação (`POST /api/obligations`):
  - Título (`title`): campo de texto obrigatório (máx. 255 caracteres).
  - Descrição (`description`): campo de texto opcional multilinhas.
  - Empresa cliente (`companyId`): seletor dropdown filtrando exclusivamente empresas com situação **Ativa** (`RN-006`).
  - Responsável atribuído (`responsibleId`): seletor dropdown filtrando exclusivamente responsáveis com situação **Ativa** (`RN-007`).
  - Prazo de entrega (`dueDate`): seletor de data (`DatePicker`) com máscara e formato brasileiro `dd/MM/yyyy` (convertido para `YYYY-MM-DD` na API).
  - Status inicial não editável: exibe aviso informativo indicando que toda nova obrigação nasce com status **Pendente** no servidor (`RN-008`).
- [x] Formulário de edição de obrigação existente (`PUT /api/obligations/{id}`):
  - Pré-carregamento dos dados atuais da obrigação.
  - Seletores de empresa e responsável permitindo troca apenas entre entidades ativas.
  - Se a obrigação já estiver com status **Concluída (`COMPLETED`)**, o formulário bloqueia alterações e exibe aviso de que obrigações concluídas não podem ser alteradas (`RN-009`).
- [x] Validações inline:
  - Título não vazio e até 255 caracteres.
  - Seleção obrigatória de empresa e responsável.
  - Data de vencimento selecionada.
- [x] Tratamento semântico de erros de negócio da API:
  - `400 VALIDATION_ERROR`: exibição de mensagens de validação.
  - `422 COMPANY_INACTIVE` / `USER_INACTIVE`: aviso explicativo de inativação.
  - `401 UNAUTHORIZED`: interceptação e redirecionamento para login.
- [x] Feedback visual com SnackBar de sucesso e recarregamento da tela de listagem / detalhes.

## 3. Regras de negócio e restrições

- **RN-006**: Empresa associada deve estar ativa no momento do vínculo.
- **RN-007**: Responsável atribuído deve estar ativo no momento do vínculo.
- **RN-008**: Toda obrigação inicia como `PENDING`. Não permitir seleção arbitrária de status inicial no cadastro.
- **RN-009**: Uma obrigação concluída (`COMPLETED`) não pode sofrer alterações cadastrais ou de status.
- **Segurança**: Cadastro e edição de obrigações requerem autenticação JWT (`requireAuth`).

## 4. Contratos e decisões técnicas

- `POST /api/obligations`: `CreateObligationRequest(companyId, responsibleId, title, description, dueDate)`.
- `PUT /api/obligations/{id}`: `UpdateObligationRequest(companyId, responsibleId, title, description, dueDate, status)`.
- `GET /api/companies?active=true`: consulta empresas ativas para popular o dropdown.
- `GET /api/responsibles?active=true`: consulta responsáveis ativos para popular o dropdown.
- Rotas nomeadas:
  - `AppRoutes.obligationCreate` (`/obligations/create`)
  - `AppRoutes.obligationEdit` (`/obligations/edit`)

## 5. Critérios de aceitação

- [x] Seletores carregam apenas empresas e responsáveis ativos.
- [x] Validações inline impedem submissão de formulário incompleto ou inválido.
- [x] Cadastro cria obrigação com status `PENDING` definido pelo backend.
- [x] Edição de obrigação ativa salva corretamente e atualiza a interface.
- [x] Tentativa de editar obrigação concluída (`COMPLETED`) é bloqueada com feedback explicativo.
- [x] Cobertura automatizada por testes unitários e de widgets.

## 6. Cenários de teste

- **Sucesso - Cadastro:** preenchimento de título, empresa ativa, responsável ativo e dueDate enviando `CreateObligationRequest`.
- **Sucesso - Edição:** abertura pré-preenchida, alteração de título/prazo e envio de `UpdateObligationRequest`.
- **Validação:** tentativa de salvar com campos vazios exibe mensagens de erro em cada campo.
- **Regra de Negócio - Entidades Inativas:** bloqueio de seleção ou exibição de aviso caso empresa/responsável seja inativado.
- **Regra de Negócio - Obrigação Concluída:** bloqueio de edição em obrigações com status `COMPLETED`.
- **Autenticação:** proteção com `requireAuth`.

## 7. Dependências

- `docs/api.md` (contratos `/api/obligations`, `/api/companies`, `/api/responsibles`).
- `frontend/lib/features/obligation/domain/entities/obligation.dart`.
- `frontend/lib/features/obligation/domain/repositories/obligation_repository.dart`.
- `frontend/lib/features/company/domain/repositories/company_repository.dart`.
- `frontend/lib/features/responsible/domain/repositories/responsible_repository.dart`.
- `frontend/lib/features/auth/presentation/widgets/auth_guard.dart`.

## 8. Pendências e pontos a confirmar

- *Resolvido:* O prazo (`dueDate`) é obrigatório no contrato REST e selecionável via DatePicker formatado. Status inicial nasce sempre como `PENDING` pelo backend.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/DlkBtqch
- Documentação de referência: `docs/api.md`, `docs/status-implementacao.md`, `docs/CHANGELOG.md`.
