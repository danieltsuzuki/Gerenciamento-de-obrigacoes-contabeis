# SPEC-012 — Adicionar testes do backend

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 12 |
| Card | [Adicionar testes do backend](https://trello.com/c/Ai2NCneJ) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Cobrir regras de domínio, serviços, controllers, persistência, autenticação e anexos por testes automatizados.

## 2. Escopo funcional

- [ ] Testar serviços e domínio.
- [ ] Testar controllers e contratos HTTP.
- [ ] Testar migrations e persistência MySQL.
- [ ] Testar CNPJ/e-mail duplicados/inválidos.
- [ ] Testar empresa/responsável inexistente ou inativo.
- [ ] Testar criação PENDING e transições de status.
- [ ] Testar anexos, limite de tamanho e obrigação inexistente.
- [ ] Gerar relatório de cobertura com JaCoCo.

## 3. Regras de negócio e restrições

- Testes devem cobrir cenários positivos e negativos.
- Testes de integração utilizam Testcontainers MySQL 8, conforme documentação.
- Cobertura registrada no status/changelog: geral acima de 86%, controllers 100%, 154 testes automatizados (na revisão registrada).

## 4. Contratos e decisões técnicas

- JUnit/stack de testes do Spring Boot e Testcontainers MySQL 8.
- JaCoCo 0.8.12; relatório HTML em target/site/jacoco/index.html.
- Swagger/OpenAPI também possui teste de integração.

## 5. Critérios de aceitação

- [ ] `mvn test` executa suíte.
- [ ] Regras críticas possuem cobertura.
- [ ] Relatório JaCoCo é gerado.
- [ ] Falhas de teste são corrigidas antes do merge.

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

- Os percentuais e quantidade são fotografia da revisão registrada no docs/status-implementacao.md e podem mudar conforme novos commits.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/Ai2NCneJ
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
