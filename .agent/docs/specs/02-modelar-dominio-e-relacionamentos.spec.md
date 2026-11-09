# SPEC-002 — Modelar domínio e relacionamentos

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 2 |
| Card | [Modelar domínio e relacionamentos](https://trello.com/c/JC3uAD5L) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Formalizar entidades do domínio e seus relacionamentos, restrições e regras essenciais.

## 2. Escopo funcional

- [ ] Modelar Company, Responsible (mapeado na tabela users), Obligation e Attachment.
- [ ] Definir Company 1:N Obligation.
- [ ] Definir Responsible 1:N Obligation.
- [ ] Definir Obligation 1:N Attachment.
- [ ] Documentar unicidade/validação de CNPJ e e-mail.
- [ ] Documentar status inicial e transições da obrigação.
- [ ] Definir comportamento para empresa/responsável inativo.

## 3. Regras de negócio e restrições

- CNPJ deve ser único e validado por dígitos verificadores.
- E-mail deve ser único e validado.
- Obligation nasce em PENDING.
- Transições válidas: PENDING → IN_PROGRESS → COMPLETED.
- COMPLETED é estado terminal.
- Empresa ou responsável inativo não recebe novas atribuições; histórico existente deve ser preservado.
- Não deve haver exclusão física/cascata que apague histórico.

## 4. Contratos e decisões técnicas

- Company: legalName, tradeName, cnpj, active, createdAt, updatedAt.
- Responsible: name, email, passwordHash, active, createdAt, updatedAt.
- Obligation: company, responsible, title, description, status, dueDate, completedAt, createdAt, updatedAt.
- Attachment: obligation, name, contentType, size, uploadedAt, storageKey/path.

## 5. Critérios de aceitação

- [ ] Diagrama ER documentado.
- [ ] Relacionamentos e constraints coerentes com docs/modelo-de-dados.md.
- [ ] Regras de domínio documentadas e rastreáveis.

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

- A nomenclatura física `users` representa a entidade de domínio Responsible. A documentação de modelo de dados registra `due_date` como obrigatório; confirmar esse requisito em evolução futura se houver divergência com o formulário/UI.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/JC3uAD5L
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
