# SPEC-023 — Adicionar testes do Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 23 |
| Card | [Adicionar testes do Flutter](https://trello.com/c/JN4XYhU1) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Criar testes automatizados para modelos, repositories e widgets das principais funcionalidades.

## 2. Escopo funcional

- [ ] Testar models e repositories.
- [ ] Criar widget tests para formulários, listagem, detalhes e status.
- [ ] Cobrir loading, vazio, erro, validações e interações principais.
- [ ] Executar suíte via flutter test.

## 3. Regras de negócio e restrições

- Testes devem verificar sucesso e falha da integração por doubles/mocks, sem depender de API real para testes unitários/widget.
- Cenários críticos das funcionalidades entregues devem estar cobertos.

## 4. Contratos e decisões técnicas

- Comando de execução: flutter test.
- Features: companies, responsibles, obligations e anexos.

## 5. Critérios de aceitação

- [ ] Suíte executa com sucesso via flutter test.
- [ ] Models/repositories possuem testes unitários.
- [ ] Widgets cobrem estados e interações críticas.

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

- O card não estabelece percentual mínimo de cobertura nem biblioteca de mocks. Não impor meta numérica sem decisão.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/JN4XYhU1
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
