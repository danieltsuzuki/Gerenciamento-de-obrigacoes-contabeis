# SPEC-014 — Implementar camada de integração com API

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 14 |
| Card | [Implementar camada de integração com API](https://trello.com/c/V7l7sJPV) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar a camada Flutter responsável por comunicação HTTP com os endpoints do backend.

## 2. Escopo funcional

- [ ] Criar clients para empresas, responsáveis, obrigações e anexos.
- [ ] Criar models/DTOs para requests e responses.
- [ ] Criar repositories por feature.
- [ ] Centralizar tratamento de falhas e conversão de respostas.
- [ ] Integrar autenticação JWT às operações protegidas.

## 3. Regras de negócio e restrições

- Widgets não devem executar chamadas HTTP diretamente.
- Estados de carregamento, sucesso e erro devem ser expostos à camada de apresentação.
- Base URL deve vir de configuração por ambiente.
- Token deve ser enviado como Bearer nas rotas protegidas.

## 4. Contratos e decisões técnicas

- Consumir contratos em docs/api.md: /api/companies, /api/responsibles, /api/obligations, /api/attachments e /api/auth.
- Paginação Spring Data: page, size, sort.
- Erros: code, message, details e timestamp.

## 5. Critérios de aceitação

- [ ] Requests/responses são mapeados sem acoplar UI aos detalhes HTTP.
- [ ] Falhas de rede, timeout, 4xx e 5xx são tratadas.
- [ ] Token JWT é anexado às requisições protegidas.
- [ ] URL configurável fora do código-fonte.

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

- O card não define pacote HTTP, política de refresh/renovação de JWT, armazenamento seguro do token ou estratégia de retry. Essas decisões precisam ser explicitadas.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/V7l7sJPV
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
