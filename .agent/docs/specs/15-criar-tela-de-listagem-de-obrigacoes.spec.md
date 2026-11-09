# SPEC-015 — Criar tela de listagem de obrigações

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 15 |
| Card | [Criar tela de listagem de obrigações](https://trello.com/c/3wpXjbhp) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Criar a tela inicial de obrigações com dados reais obtidos pela API.

## 2. Escopo funcional

- [ ] Listar obrigações.
- [ ] Exibir título, empresa, responsável, status, quantidade de anexos e data de criação.
- [ ] Exibir loading, erro e estado vazio.
- [ ] Atualizar listagem após ações que alterem dados.
- [ ] Permitir abrir a tela de detalhes ao selecionar um item.

## 3. Regras de negócio e restrições

- Status deve ser distinguível visualmente e também por texto.
- A lista deve refletir os dados retornados pela API, sem inventar estado local.
- Falhas de carregamento devem permitir feedback adequado.

## 4. Contratos e decisões técnicas

- Consumir GET /api/obligations com paginação/filtros disponíveis.
- Campos de exibição: title, company, responsible, status, attachmentCount, createdAt.

## 5. Critérios de aceitação

- [ ] Dados são carregados da API.
- [ ] Cada item abre detalhes.
- [ ] Loading, erro e vazio são exibidos corretamente.
- [ ] Após ações, os dados são atualizados.

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
