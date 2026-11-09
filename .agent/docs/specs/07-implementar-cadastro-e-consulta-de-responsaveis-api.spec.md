# SPEC-007 — Implementar cadastro e consulta de responsáveis (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 7 |
| Card | [Implementar cadastro e consulta de responsáveis (API)](https://trello.com/c/Lq9Oed4J) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — endpoints REST, segurança JWT, hash BCrypt e testes de integração implementados |

## 1. Objetivo

Disponibilizar API para cadastro, consulta, listagem e atualização de responsáveis. O estado atual também inclui autenticação JWT registrada no histórico do card e em docs/api.md.

## 2. Escopo funcional

- [x] POST /api/responsibles cadastra responsável (`ResponsibleController#create`).
- [x] GET /api/responsibles lista com paginação e filtro active opcional (`ResponsibleController#list`).
- [x] GET /api/responsibles/{id} consulta responsável sem expor senha/hash (`ResponsibleController#getById`).
- [x] PUT /api/responsibles/{id} atualiza nome, e-mail e active (`ResponsibleController#update`).
- [x] POST /api/auth/register registra usuário (`AuthController#register`).
- [x] POST /api/auth/login autentica e emite JWT (`AuthController#login`).

## 3. Regras de negócio e restrições

- E-mail é obrigatório, validado e único (RN-003).
- Senha nunca é retornada em DTO de resposta; persistir hash BCrypt (RN-007).
- Usuários inativos não podem autenticar (401).
- GET de consulta é anônimo; mutações protegidas por JWT, exceto register/login (`docs/api.md`).
- Inativação lógica por active=false; sem DELETE físico (RN-004, ADR-0001).

## 4. Contratos e decisões técnicas

- POST /api/responsibles: name, email, password, active (senha 6–100 caracteres).
- GET list: active opcional, page=0, size=20, sort=id,asc (Spring Data Pageable).
- PUT: name, email, active.
- POST /api/auth/register e POST /api/auth/login.
- JWT Bearer; expiração padrão 30 minutos (1800000ms configurável via JWT_EXPIRATION_MS).

## 5. Critérios de aceitação

- [x] CRUD de responsáveis e autenticação funcionam conforme contrato.
- [x] E-mail duplicado retorna 409/422 DUPLICATE_EMAIL.
- [x] Credenciais inválidas/inativo retornam 401.
- [x] Resposta não contém password/hash.
- [x] Testes unitários, WebMvc e integração MySQL cobrem fluxos.

## 6. Cenários de teste

- **Sucesso:** ciclo completo de criação, consulta, atualização, login e geração de JWT (`ResponsibleApiIntegrationTest#testResponsibleApiLifecycle`).
- **Validação:** validação de formato de e-mail e restrições de tamanho (`ResponsibleControllerTest`).
- **Falha de dependência:** rejeição de e-mail duplicado (`ResponsibleServiceTest`, `DatabaseMigrationIntegrationTest`).
- **Regressão:** bloqueio de requisições `DELETE` com `405 Method Not Allowed`.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- Cadastro público (register) mantido conforme documentação de onboarding do sistema.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/Lq9Oed4J
- Documentação de referência: `docs/api.md`, `docs/arquitetura.md`, `docs/index.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
