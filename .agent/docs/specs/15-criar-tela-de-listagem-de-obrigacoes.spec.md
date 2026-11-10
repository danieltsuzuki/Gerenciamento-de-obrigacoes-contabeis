# SPEC-015 — Criar tela de listagem de obrigações

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 15 |
| Card | [Criar tela de listagem de obrigações](https://trello.com/c/3wpXjbhp) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Criar a tela inicial de obrigações com dados reais obtidos pela API.

## 2. Escopo funcional

- [x] Listar obrigações.
- [x] Exibir título, empresa, responsável, status, quantidade de anexos e data de criação.
- [x] Exibir loading, erro e estado vazio.
- [x] Atualizar listagem após ações que alterem dados.
- [x] Permitir abrir a tela de detalhes ao selecionar um item.

## 3. Regras de negócio e restrições

- Status deve ser distinguível visualmente (cores semânticas, bordas e ícones) e também por texto.
- A lista deve refletir os dados retornados pela API, sem inventar estado local.
- Falhas de carregamento devem permitir feedback adequado com retry (`ErrorStateView`).
- O vencimento (`dueDate`) deve destacar visualmente status de atraso (`isOverdue`).

## 4. Contratos e decisões técnicas

- Consumir `GET /api/obligations` via `ObligationRepository.getObligations` com paginação Spring Data e filtro opcional por `ObligationStatus`.
- Campos de exibição no card: `title`, `description`, `company.name`, `responsible.name`, `status` (com badge temático e ícone), `attachmentCount`, `createdAt` e `dueDate` formatados (`dd/MM/yyyy`).
- Barra superior de filtros rápidos com `ChoiceChip`s para filtragem dinâmica entre "Todas", "Pendentes", "Em Andamento" e "Concluídas".
- Seleção de item com suporte a callback `onObligationTap` e navegação para `AppRoutes.obligationDetails`.
- Atualização dinâmica após ações via `RefreshIndicator`, botão de recarregar e recarregamento automático após retorno de telas de detalhe/criação.

## 5. Critérios de aceitação

- [x] Dados são carregados da API.
- [x] Cada item abre detalhes.
- [x] Loading, erro e vazio são exibidos corretamente.
- [x] Após ações, os dados são atualizados.

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

- O card não especifica filtros, busca textual, ordenação visual, paginação infinita ou layout responsivo. Não assumir esses recursos como escopo obrigatório.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/3wpXjbhp
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
