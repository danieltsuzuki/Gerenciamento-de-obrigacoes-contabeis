# SPEC-005 — Implementar entidades e mapeamentos JPA

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 5 |
| Card | [Implementar entidades e mapeamentos JPA](https://trello.com/c/cyN0GakG) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar entidades, enums, relacionamentos e repositories do domínio.

## 2. Escopo funcional

- [ ] Implementar Company, Responsible, Obligation e Attachment.
- [ ] Implementar enum de status da obrigação.
- [ ] Mapear relacionamentos JPA.
- [ ] Criar repositories com operações necessárias de leitura, gravação e consulta.
- [ ] Garantir persistência e recuperação dos relacionamentos.

## 3. Regras de negócio e restrições

- Relações para entidades-pai usam ManyToOne LAZY e optional=false, conforme modelo documentado.
- Não usar cascata de remoção nem orphanRemoval.
- Repositories não devem expor métodos delete* (ADR-0001).
- Inativação de Company e Responsible é feita por `active`, preservando histórico.

## 4. Contratos e decisões técnicas

- Campos mínimos: Company legalName, tradeName, cnpj, active; Responsible name, email, active e passwordHash; Obligation title, description, company, responsible, status, dueDate, completedAt, createdAt; Attachment name, contentType, size, uploadedAt, storageKey/path, obligation.
- Tabelas: company, users, obligation, attachment.

## 5. Critérios de aceitação

- [ ] Entidades persistem e recuperam relacionamentos corretamente.
- [ ] Enums e transições respeitam o domínio.
- [ ] Repositories não oferecem exclusão física.
- [ ] Testes de domínio e integração MySQL aprovados.

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

- A documentação registra auditoria e relações LAZY. Evitar adicionar coleções bidirecionais/cascatas sem decisão arquitetural.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/cyN0GakG
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
