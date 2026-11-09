# SPEC-003 — Criar repositório e estrutura do backend

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 3 |
| Card | [Criar repositório e estrutura do backend](https://trello.com/c/WvGyaN2y) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Criar a aplicação backend e preparar a estrutura de execução e desenvolvimento.

## 2. Escopo funcional

- [ ] Criar projeto Java 21 com Spring Boot.
- [ ] Configurar profiles de execução.
- [ ] Organizar packages por domínio/feature e camadas.
- [ ] Adicionar dependências Web, Validation, Data JPA, MySQL, Flyway e testes.
- [ ] Configurar formatação e .gitignore.
- [ ] Disponibilizar endpoint de health.

## 3. Regras de negócio e restrições

- Configurações sensíveis devem ficar fora do código-fonte.
- A aplicação deve iniciar localmente.

## 4. Contratos e decisões técnicas

- Java 21; Spring Boot; Maven ou Gradle (o card não fixa qual dos dois).
- Dependências: Spring Web, Bean Validation, Spring Data JPA, MySQL, Flyway e testes.

## 5. Critérios de aceitação

- [ ] Aplicação inicia localmente sem erro.
- [ ] Endpoint de health responde.
- [ ] Estrutura de pacotes e dependências está configurada.

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

- O card não especifica o endpoint exato de health nem os profiles existentes; seguir o repositório real.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/WvGyaN2y
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
