# SPEC-014 — Implementar camada de integração com API

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 14 |
| Card | [Implementar camada de integração com API](https://trello.com/c/V7l7sJPV) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Implementar a camada Flutter responsável por comunicação HTTP com os endpoints do backend.

## 2. Escopo funcional

- [x] Criar clients para empresas, responsáveis, obrigações e anexos.
- [x] Criar models/DTOs para requests e responses.
- [x] Criar repositories por feature.
- [x] Centralizar tratamento de falhas e conversão de respostas.
- [x] Integrar autenticação JWT às operações protegidas.

## 3. Regras de negócio e restrições

- Widgets não devem executar chamadas HTTP diretamente.
- Estados de carregamento, sucesso e erro devem ser expostos à camada de apresentação.
- Base URL deve vir de configuração por ambiente (`AppConfig`).
- Token deve ser enviado como Bearer nas rotas protegidas (`ApiClient.setAuthToken`).

## 4. Contratos e decisões técnicas

- Consumir contratos em docs/api.md: `/api/companies`, `/api/responsibles`, `/api/obligations`, `/api/attachments` e `/api/auth`.
- Paginação Spring Data deserializada genericamente via `PageResponse<T>` (`content`, `totalElements`, `totalPages`, `size`, `number`, `first`, `last`, `empty`).
- Erros da API mapeados via `ApiException` estruturada (`code`, `message`, `details`, `timestamp`, `statusCode`).
- Upload multipart com token Bearer via `ApiClient.multipartRequest`.
- Download de arquivo com extração do header `Content-Disposition` via `ApiClient.download` retornando `DownloadedFile`.

## 5. Critérios de aceitação

- [x] Requests/responses são mapeados sem acoplar UI aos detalhes HTTP.
- [x] Falhas de rede, timeout, 4xx e 5xx são tratadas.
- [x] Token JWT é anexado às requisições protegidas.
- [x] URL configurável fora do código-fonte.

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
