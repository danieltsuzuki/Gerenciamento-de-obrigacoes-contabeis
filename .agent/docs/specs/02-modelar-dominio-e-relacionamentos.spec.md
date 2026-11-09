# SPEC-002 — Modelar domínio e relacionamentos

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 2 |
| Card | [Modelar domínio e relacionamentos](https://trello.com/c/JC3uAD5L) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — formalizada em `docs/modelo-de-dados.md`, entidades JPA e testes de persistência |

## 1. Objetivo

Formalizar entidades do domínio e seus relacionamentos, restrições e regras essenciais.

## 2. Escopo funcional

- [x] Modelar Company, Responsible (mapeado na tabela users), Obligation e Attachment.
- [x] Definir Company 1:N Obligation.
- [x] Definir Responsible 1:N Obligation.
- [x] Definir Obligation 1:N Attachment.
- [x] Documentar unicidade/validação de CNPJ e e-mail.
- [x] Documentar status inicial e transições da obrigação.
- [x] Definir comportamento para empresa/responsável inativo.

## 3. Regras de negócio e restrições

- CNPJ deve ser único e validado por dígitos verificadores (RN-001 e RN-002).
- E-mail deve ser único e validado (RN-003).
- Obligation nasce em PENDING (RN-008).
- Transições válidas: PENDING → IN_PROGRESS → COMPLETED (RN-008).
- COMPLETED é estado terminal (RN-008).
- Empresa ou responsável inativo não recebe novas atribuições; histórico existente deve ser preservado (RN-006).
- Não deve haver exclusão física/cascata que apague histórico (RN-004 e RN-005, ADR-0001).

## 4. Contratos e decisões técnicas

- Company: legalName, tradeName, cnpj, active, createdAt, updatedAt.
- Responsible: name, email, passwordHash, active, createdAt, updatedAt.
- Obligation: company, responsible, title, description, status, dueDate, completedAt, createdAt, updatedAt.
- Attachment: obligation, name, contentType, size, uploadedAt, storageKey/path.

## 5. Critérios de aceitação

- [x] Diagrama ER documentado (`docs/modelo-de-dados.md`).
- [x] Relacionamentos e constraints coerentes com `docs/modelo-de-dados.md`.
- [x] Regras de domínio documentadas e rastreáveis (`docs/status-implementacao.md`).

## 6. Cenários de teste

- **Sucesso:** validar o fluxo principal descrito nesta SPEC (`DomainPersistenceIntegrationTest`).
- **Validação:** rejeitar dados obrigatórios ausentes ou inválidos.
- **Falha de dependência:** apresentar erro apropriado quando API, banco ou storage não estiver disponível.
- **Regressão:** garantir que a funcionalidade não viole regras existentes do domínio.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- A nomenclatura física `users` representa a entidade de domínio Responsible. A documentação de modelo de dados registra `due_date` como obrigatório (`NOT NULL`).

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/JC3uAD5L
- Documentação de referência: `docs/modelo-de-dados.md`, `docs/arquitetura.md`, `docs/index.md`, `docs/api.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
