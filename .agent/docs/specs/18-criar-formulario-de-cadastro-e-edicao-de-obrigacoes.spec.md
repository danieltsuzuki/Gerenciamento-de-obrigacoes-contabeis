# SPEC-018 — Criar formulário de cadastro e edição de obrigações

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 18 |
| Card | [Criar formulário de cadastro e edição de obrigações](https://trello.com/c/DlkBtqch) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar formulários Flutter para criação e edição de obrigações.

## 2. Escopo funcional

- [ ] Campos: título, descrição, empresa, responsável e prazo (dueDate conforme contrato da API).
- [ ] Carregar empresas ativas e responsáveis ativos para seleção.
- [ ] Não permitir salvar sem associações válidas.
- [ ] No cadastro, não permitir edição do status inicial; backend define PENDING.
- [ ] Integrar criação/edição à API e apresentar feedback.

## 3. Regras de negócio e restrições

- Empresa e responsável selecionados devem existir e estar ativos.
- Status inicial é definido pelo backend como PENDING.
- Não enviar status escolhido pelo usuário no cadastro.
- Na edição, alterações de vínculo devem respeitar ativos.

## 4. Contratos e decisões técnicas

- POST /api/obligations: companyId, responsibleId, title, description opcional, dueDate.
- PUT /api/obligations/{id}: companyId, responsibleId, title, description, dueDate e status opcional conforme docs/api.md.

## 5. Critérios de aceitação

- [ ] Seletores carregam somente opções ativas.
- [ ] Validações impedem submissão inválida.
- [ ] Cadastro cria obrigação PENDING pelo backend.
- [ ] Edição salva e reflete resposta do servidor.

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

- O card não lista dueDate entre os campos, mas o contrato API e modelo de dados o definem como obrigatório. Incluir o prazo no formulário por consistência e confirmar UX/data de negócio.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/DlkBtqch
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
