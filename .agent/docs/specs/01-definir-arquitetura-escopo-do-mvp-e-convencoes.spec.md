# SPEC-001 — Definir arquitetura, escopo do MVP e convenções

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 1 |
| Card | [Definir arquitetura, escopo do MVP e convenções](https://trello.com/c/tFmtVqaG) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — formalizada em `docs/arquitetura.md` e `README.md` |

## 1. Objetivo

Registrar decisões técnicas e limites do MVP. Backend em camadas/feature packages; Flutter organizado por features; convenções REST/JSON, nomes, paginação e erros; anexos no filesystem local com metadados no MySQL e caminho configurável.

## 2. Escopo funcional

- [x] Definir organização do backend por domínio/feature e camadas (`docs/arquitetura.md`).
- [x] Definir organização Flutter por features e camadas data/domain/presentation (`docs/arquitetura.md`).
- [x] Documentar convenções REST, JSON, nomenclatura, paginação e erros (`docs/arquitetura.md`, `docs/api.md`).
- [x] Definir armazenamento local de anexos com metadados no MySQL (`docs/arquitetura.md`, `FileStorage`, `LocalFileSystemStorage`).
- [x] Registrar limites e decisões do MVP (`docs/arquitetura.md`, `README.md`).

## 3. Regras de negócio e restrições

- As decisões devem ser compartilhadas e coerentes entre frontend e backend.
- MVP armazena binários no filesystem local; metadados ficam no MySQL.

## 4. Contratos e decisões técnicas

- Backend: Java 21, Spring Boot, Maven, Spring Web, Validation, Data JPA, MySQL, Flyway e testes.
- Frontend: Flutter, organização feature-first com camadas data/domain/presentation.
- Persistência: MySQL 8; migrations Flyway.
- Anexos: filesystem local configurável (`LocalFileSystemStorage`), compensação em falha de BD.

## 5. Critérios de aceitação

- [x] Documentação de arquitetura/README alinhada entre frontend e backend (`docs/arquitetura.md`, `README.md`).
- [x] Convenções e limites do MVP registrados (`docs/arquitetura.md`).
- [x] Estratégia de armazenamento de anexos documentada (`docs/arquitetura.md`).

## 6. Cenários de teste

- **Sucesso:** validar o fluxo principal descrito nesta SPEC (cobertura com 154 testes no backend, JaCoCo >86%).
- **Validação:** rejeitar dados obrigatórios ausentes ou inválidos.
- **Falha de dependência:** apresentar erro apropriado quando API, banco ou storage não estiver disponível.
- **Regressão:** garantir que a funcionalidade não viole regras existentes do domínio.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações do backend e futuras implementações do Flutter.

## 8. Pendências e pontos a confirmar

- Decisões pós-MVP registradas em `docs/pendencias-e-perguntas-em-aberto.md` (RBAC, recorrência em lote, imutabilidade de anexos em concluídas).

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/tFmtVqaG
- Documentação de referência: `docs/arquitetura.md`, `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e `docs/decisoes/ADR-0001-repositories-sem-operacoes-de-exclusao.md`.
