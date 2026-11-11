# SPEC-023 — Adicionar testes do Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 23 |
| Card | [Adicionar testes do Flutter](https://trello.com/c/JN4XYhU1) |
| Status no Trello (10/11/2026) | Concluído |
| Versão da SPEC | 1.2 |
| Situação da especificação | Concluída e testada |

## 1. Objetivo

Criar testes automatizados para modelos, repositories e widgets das principais funcionalidades, garantindo resiliência total e zero exceções não tratadas.

## 2. Escopo funcional

- [x] Testar models e repositories.
- [x] Criar widget tests para formulários, listagem, detalhes e status.
- [x] Cobrir loading, vazio, erro, validações e interações principais.
- [x] Garantir que não haja exceções ou erros não tratados na aplicação nem na execução dos testes.
- [x] Executar suíte via flutter test.

## 3. Regras de negócio e restrições

- Testes devem verificar sucesso e falha da integração por doubles/mocks, sem depender de API real para testes unitários/widget.
- Cenários críticos das funcionalidades entregues devem estar cobertos.
- **Tratamento estrito de erros e exceções:** nenhuma exceção de rede, parsing de dados degenerados ou erro da API (400, 401, 404, 409, 422, 500) pode vazar sem captura ou causar falha não tratada na interface.

## 4. Contratos e decisões técnicas

- Comando de execução: flutter test.
- Features: companies, responsibles, obligations, anexos e autenticação.
- 172 testes automatizados cobrindo modelos de domínio, DTOs de requisição/resposta, validação de regras de transição de status (RN-008), ciclo de vida de anexos, tratamento robusto de erros e fluxos visuais completos.

## 5. Critérios de aceitação

- [x] Suíte executa com sucesso via flutter test (172 testes aprovados).
- [x] Models/repositories possuem testes unitários.
- [x] Widgets cobrem estados e interações críticas (loading, empty, error, formulários e detalhes).
- [x] **Não pode haver exceções e erros não tratados:** a aplicação trata e absorve falhas de conexão, payloads degenerados, respostas HTTP de erro (409 DUPLICATE_CNPJ, 409 DUPLICATE_EMAIL, 422 INVALID_STATUS_TRANSITION, 500 INTERNAL_SERVER_ERROR) exibindo feedback adequado sem disparar exceções não tratadas no framework Flutter.

## 6. Cenários de teste

- **Sucesso:** validar desserialização e serialização de entidades e DTOs das features de Company, Responsible, Obligation, Attachment e Auth.
- **Validação:** validação de CNPJ, e-mail, formatos de data e máquina de estados de obrigações.
- **Falha de dependência e resiliência:** respostas da API mapeadas para `ApiException` com tratamento em ErrorStateView e SnackBar, garantindo zero exceções não tratadas.
- **Regressão:** garantir integridade de todas as especificações frontend entregues.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`, quando aplicável.
- Modelo de dados em `docs/modelo-de-dados.md`, quando aplicável.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- Nenhuma pendência em aberto.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/JN4XYhU1
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
