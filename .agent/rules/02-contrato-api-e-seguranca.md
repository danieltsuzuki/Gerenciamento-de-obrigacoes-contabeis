# Contrato da API e segurança

Antes de criar ou alterar endpoints, consulte `docs/api.md` e os controllers/DTOs atuais.

## Convenções obrigatórias
- Prefixo documentado: `/api`.
- Controllers recebem e retornam DTOs; não exponha entidades JPA.
- Mantenha payloads, códigos de erro, status HTTP, paginação e filtros compatíveis com `docs/api.md`.
- GETs são anônimos. Operações de mutação exigem `Authorization: Bearer <token>`, exceto `POST /api/auth/login` e `POST /api/auth/register`.
- Operações de anexos (upload, listagem e download) exigem JWT, conforme `docs/api.md`.
- Erros devem manter o contrato documentado, incluindo `VALIDATION_ERROR`, `UNAUTHORIZED`, `NOT_FOUND`, `INVALID_STATUS_TRANSITION`, `COMPANY_INACTIVE` e `USER_INACTIVE`, quando aplicáveis.
- Não adicione `DELETE` para recursos com histórico.

## Endpoints documentados
- Autenticação: `/api/auth/register`, `/api/auth/login`.
- Empresas: `/api/companies`.
- Responsáveis: `/api/responsibles`.
- Obrigações: `/api/obligations`; alteração explícita de status em `/api/obligations/{id}/status`.
- Anexos: `/api/obligations/{id}/attachments` e `/api/attachments/{attachmentId}/download`.

Os métodos, payloads completos, filtros, paginação e respostas estão em `docs/api.md`; não replique contratos inteiros nesta Rule.

## Não presumir
- Não invente autorização por perfil ou regra de que apenas o responsável atribuído pode alterar uma obrigação.
- Não invente refresh token, logout com revogação, escopos ou novos papéis.
- Não altere a política de acesso anônimo/protegido sem atualizar segurança, documentação e testes.
- A documentação tem uma diferença a observar: o `PUT /api/obligations/{id}` aceita status opcional e também existe `PATCH` dedicado. Preserve o comportamento atual até decisão explícita.
