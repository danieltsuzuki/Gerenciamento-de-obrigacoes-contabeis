# SPEC-027 — Consolidar diferenciais já implementados (Autenticação, OpenAPI/Swagger, Upload físico)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar: "Diferenciais: Autenticação, Swagger e Upload físico") |
| Card | — |
| Status | Concluído (especificação retroativa para rastreabilidade) |
| Versão da SPEC | 1.0 |
| Situação da especificação | Retroativa — consolida comportamento já implementado e documentado |
| Tipo | Diferencial (não obrigatório) |

## 1. Objetivo

Registrar formalmente, em uma especificação rastreável, os diferenciais do enunciado que já foram entregues em outras SPECs, mas que não possuíam card/especificação própria: **Autenticação**, **OpenAPI/Swagger** e **Upload físico de arquivos**.

## 2. Escopo funcional

- [x] **Autenticação (backend):** JWT stateless com `POST /api/auth/login` e `POST /api/auth/register`; senhas com BCrypt; `JwtAuthenticationFilter`; mutações (`POST/PUT/PATCH`) e anexos exigem Bearer; `GET` de leitura é anônimo.
- [x] **Autenticação (frontend):** tela de login/registro, sessão persistida com `flutter_secure_storage`, `AuthGuard` e redirecionamento em `401` (SPEC-026).
- [x] **OpenAPI/Swagger:** SpringDoc com Swagger UI em `/swagger-ui.html`, contrato em `/v3/api-docs` e esquema `bearerAuth` (botão Authorize).
- [x] **Upload físico de arquivos:** armazenamento em filesystem configurável (`STORAGE_LOCATION`), caminho `{obligationId}/{uuid}.{ext}` gerado no servidor, proteção contra path traversal, compensação em falha de banco, limite de 10 MB e allowlist de MIME (SPEC-010, SPEC-021, SPEC-022).

## 3. Regras de negócio e restrições

- Não introduzir perfis, papéis, refresh token ou autorização por responsável (não especificados — regra 01).
- Hash de senha nunca exposto em DTOs.
- Nome do arquivo enviado pelo cliente nunca é usado como caminho.

## 4. Contratos e decisões técnicas

- Contratos em `docs/api.md` (seções Autenticação, Swagger e Anexos).
- Dependências: `spring-boot-starter-security`, `jjwt` 0.12.6, `springdoc-openapi-starter-webmvc-ui`.

## 5. Critérios de aceitação

- [x] Login retorna token válido; requisições de mutação sem token retornam `401`.
- [x] Swagger UI acessível e operações protegidas executáveis após Authorize.
- [x] Upload grava binário em disco e metadados (`name`, `contentType`, `size`, `uploadedAt`) no MySQL.
- [x] Download devolve o binário com `Content-Disposition` sanitizado.

## 6. Cenários de teste

- **Sucesso:** `AuthControllerTest`, `AttachmentApiIntegrationTest`, `LocalFileSystemStorageTest`, testes Flutter de login e upload/download.
- **Validação:** credenciais inválidas (`401 BAD_CREDENTIALS`), arquivo vazio/MIME inválido (`400`).
- **Falha de dependência:** falha de I/O → `500 STORAGE_ERROR` com compensação.
- **Regressão:** `GET` anônimo continua permitido.

## 7. Dependências

- SPEC-010, SPEC-021, SPEC-022, SPEC-024, SPEC-026.

## 8. Pendências e pontos a confirmar

- Remover o valor padrão de `jwt.secret` em `application.yml` (tratado na SPEC-029).

## 9. Rastreabilidade

- `docs/api.md`, `README.md`, `docs/status-implementacao.md`.

