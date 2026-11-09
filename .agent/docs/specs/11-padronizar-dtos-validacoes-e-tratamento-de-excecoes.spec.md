# SPEC-011 — Padronizar DTOs, validações e tratamento de exceções

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 11 |
| Card | [Padronizar DTOs, validações e tratamento de exceções](https://trello.com/c/OARCmyxB) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Padronizar contratos de entrada/saída, validação dos payloads e respostas de erro da API.

## 2. Escopo funcional

- [x] Separar DTOs das entidades JPA.
- [x] Aplicar Bean Validation nos requests.
- [x] Implementar tratamento global de exceções.
- [x] Padronizar códigos HTTP e payload JSON.
- [x] Não expor stack trace, senha, hash ou detalhes internos.

## 3. Regras de negócio e restrições

- 400 para validação/payload inválido.
- 401 para autenticação ausente/inválida ou credenciais incorretas.
- 404 para recurso inexistente.
- 409 para CNPJ/e-mail duplicado.
- 422 para regras de negócio e transições inválidas.
- 405 para métodos não permitidos, incluindo DELETE físico.
- 500 para falha interna/storage.

## 4. Contratos e decisões técnicas

- Formato de erro documentado: code, message, details opcional, timestamp.
- Exceções e códigos devem seguir docs/api.md.
- DTOs de response nunca expõem passwordHash.

## 5. Critérios de aceitação

- [x] Erros de validação, ausência, duplicidade e transição inválida têm status/mensagem consistentes.
- [x] Nenhuma resposta expõe stack trace/dados internos.
- [x] Controllers usam DTOs e não entidades JPA diretamente.

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

- A especificação geral cita 413 quando aplicável, mas docs/api.md e CHANGELOG.md registram tamanho excedido como 400. Manter o comportamento efetivamente implementado/documentado e decidir explicitamente se 413 será adotado.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/OARCmyxB
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
