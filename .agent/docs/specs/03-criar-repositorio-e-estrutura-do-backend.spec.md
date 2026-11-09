# SPEC-003 — Criar repositório e estrutura do backend

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 3 |
| Card | [Criar repositório e estrutura do backend](https://trello.com/c/WvGyaN2y) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — projeto configurado, packages organizados, health check liberado e testado |

## 1. Objetivo

Criar a aplicação backend e preparar a estrutura de execução e desenvolvimento.

## 2. Escopo funcional

- [x] Criar projeto Java 21 com Spring Boot (`pom.xml`).
- [x] Configurar profiles de execução (`application.yml`, `application-dev.yml`).
- [x] Organizar packages por domínio/feature e camadas (`docs/arquitetura.md`).
- [x] Adicionar dependências Web, Validation, Data JPA, MySQL, Flyway e testes (`pom.xml`).
- [x] Configurar formatação e .gitignore (`.gitignore`).
- [x] Disponibilizar endpoint de health (`/actuator/health` público via `SecurityConfig` e `management` no `application.yml`).

## 3. Regras de negócio e restrições

- Configurações sensíveis devem ficar fora do código-fonte (lidas via `.env`/variáveis de ambiente).
- A aplicação deve iniciar localmente.

## 4. Contratos e decisões técnicas

- Java 21; Spring Boot; Maven.
- Dependências: Spring Web, Bean Validation, Spring Data JPA, MySQL, Flyway, Actuator, Security/JJWT, SpringDoc OpenAPI e testes (JUnit 5, Mockito, Testcontainers).

## 5. Critérios de aceitação

- [x] Aplicação inicia localmente sem erro (`BUILD SUCCESS`).
- [x] Endpoint de health responde (`/actuator/health` configurado em `SecurityConfig` e testado em `ActuatorHealthTest`).
- [x] Estrutura de pacotes e dependências está configurada (`docs/arquitetura.md`).

## 6. Cenários de teste

- **Sucesso:** validar o fluxo principal descrito nesta SPEC (`ActuatorHealthTest` e suíte de testes).
- **Validação:** rejeitar dados obrigatórios ausentes ou inválidos.
- **Falha de dependência:** apresentar erro apropriado quando API, banco ou storage não estiver disponível.
- **Regressão:** garantir que a funcionalidade não viole regras existentes do domínio.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- Endpoint de health padronizado em `/actuator/health`, com acesso público sem necessidade de token para monitoramento e probes de infraestrutura.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/WvGyaN2y
- Documentação de referência: `docs/arquitetura.md`, `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
