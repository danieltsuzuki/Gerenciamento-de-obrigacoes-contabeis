# SPEC-005 — Implementar entidades e mapeamentos JPA

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 5 |
| Card | [Implementar entidades e mapeamentos JPA](https://trello.com/c/cyN0GakG) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — entidades, mapeamentos JPA e repositories sem exclusão física implementados e testados |

## 1. Objetivo

Implementar entidades, enums, relacionamentos e repositories do domínio.

## 2. Escopo funcional

- [x] Implementar Company, Responsible, Obligation e Attachment (`Company.java`, `Responsible.java`, `Obligation.java`, `Attachment.java`).
- [x] Implementar enum de status da obrigação (`ObligationStatus.java`).
- [x] Mapear relacionamentos JPA (`@ManyToOne(fetch = LAZY, optional = false)` sem cascade).
- [x] Criar repositories com operações necessárias de leitura, gravação e consulta (`CompanyRepository`, `ResponsibleRepository`, `ObligationRepository`, `AttachmentRepository`).
- [x] Garantir persistência e recuperação dos relacionamentos (`DomainPersistenceIntegrationTest`).

## 3. Regras de negócio e restrições

- Relações para entidades-pai usam ManyToOne LAZY e optional=false, conforme modelo documentado.
- Não usar cascata de remoção nem orphanRemoval.
- Repositories não devem expor métodos delete* (ADR-0001, RN-004).
- Inativação de Company e Responsible é feita por `active`, preservando histórico.

## 4. Contratos e decisões técnicas

- Campos mínimos: Company legalName, tradeName, cnpj, active; Responsible name, email, active e passwordHash; Obligation title, description, company, responsible, status, dueDate, completedAt, createdAt; Attachment name, contentType, size, uploadedAt, storageKey/path, obligation.
- Tabelas: company, users, obligation, attachment.

## 5. Critérios de aceitação

- [x] Entidades persistem e recuperam relacionamentos corretamente (`DomainPersistenceIntegrationTest`).
- [x] Enums e transições respeitam o domínio (`ObligationStatusTest`, `ObligationChangeStatusTest`).
- [x] Repositories não oferecem exclusão física (`RepositoriesDoNotExposeDeleteTest`).
- [x] Testes de domínio e integração MySQL aprovados.

## 6. Cenários de teste

- **Sucesso:** salvar e carregar entidades com relacionamentos (`DomainPersistenceIntegrationTest#saveAndReloadEachEntity`).
- **Validação:** validação de regras de máquina de estados de `Obligation` (`ObligationChangeStatusTest`).
- **Falha de dependência:** integridade referencial sem cascade rejeita exclusão física (`databaseRefusesToDeleteCompanyWithObligation`).
- **Regressão:** reflexão garante ausência de métodos `delete*` nos repositories (`RepositoriesDoNotExposeDeleteTest`).

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- A documentação registra auditoria e relações LAZY. Relações bidirecionais e cascatas continuam proibidas por arquitetura.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/cyN0GakG
- Documentação de referência: `docs/modelo-de-dados.md`, `docs/arquitetura.md`, `docs/index.md`, `docs/api.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
