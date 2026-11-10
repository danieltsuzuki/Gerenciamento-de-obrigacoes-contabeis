# SPEC-026 — Implementar autenticação e tela de login no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (sem card dedicado; unificada com a especificação da tela de login) |
| Card | — |
| Status (10/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — implementada e testada (unificação das especificações de autenticação e tela de login) |

## 1. Objetivo

Implementar no frontend Flutter o fluxo completo de autenticação JWT definido pelo backend: tela de login (`LoginPage`), botão de login no canto superior direito do AppBar (`AppScaffold`), tela de autocadastro (`RegisterPage`), gerenciador de sessão (`AuthSessionController`), persistência segura (`AuthSessionStorage`), injeção automática de token Bearer nas operações protegidas, guarda de rotas/ações (`requireAuth`) e tratamento semântico de erros e sessão expirada (`401 UNAUTHORIZED`).

## 2. Escopo funcional

- [x] Construir a tela de login (`LoginPage`) com e-mail, senha, alternância de visibilidade de senha (ícone de olho), indicador de progresso e banner de erro amigável (`401 BAD_CREDENTIALS`).
- [x] Adicionar botão de "Login" destacado no canto superior direito da tela (`AppScaffold`), visível tanto em modo anônimo quanto quando o controlador não for injetado.
- [x] Criar tela de autocadastro (`RegisterPage`) com nome, e-mail, senha (6 a 100 caracteres), confirmação de senha e auto-login pós-cadastro.
- [x] Gerenciar a sessão autenticada (token JWT + dados do responsável) em um controlador de sessão compartilhado (`AuthSessionController`).
- [x] Persistir a sessão localmente de forma segura (`AuthSessionStorage` / `flutter_secure_storage`) para manter o usuário autenticado entre reinicializações.
- [x] Injetar automaticamente o token no `ApiClient` (`Authorization: Bearer <token>`) após login e na restauração da sessão.
- [x] Exibir na interface o usuário autenticado com avatar/primeiro nome e menu de opções contendo ação de logout.
- [x] Proteger ações de mutação (criar/editar empresas, criar obrigações) e anexos via `requireAuth`, exigindo login antes de executá-las e retomando o fluxo após autenticação.
- [x] Tratar `401 UNAUTHORIZED` em qualquer requisição autenticada: limpar sessão e redirecionar para o login, preservando a navegação de leitura anônima.

## 3. Regras de negócio e restrições

Regras extraídas da documentação do backend (`docs/api.md` — *Autenticação e Autorização (JWT)*):

| ID | Regra | Comportamento esperado no frontend |
|---|---|---|
| AUTH-01 | `GET /api/companies/**`, `GET /api/responsibles/**` e `GET /api/obligations/**` (exceto anexos) são **anônimos**. | Listagens e detalhes funcionam sem login. O app **não** deve exigir login na inicialização. |
| AUTH-02 | `POST`, `PUT` e `PATCH` em `/api/**` exigem Bearer JWT, exceto `POST /api/auth/login` e `POST /api/auth/register`. | Botões de criar/editar/alterar status exigem sessão ativa; sem sessão, redirecionar ao login e retornar ao fluxo após autenticar. |
| AUTH-03 | Todas as operações de anexos (`/api/obligations/*/attachments/**`, `/api/attachments/**`) — upload, listagem e download — exigem Bearer JWT. | Seção de anexos só carrega com sessão; sem sessão, exibir convite para login. |
| AUTH-04 | Login (`POST /api/auth/login`) autentica apenas responsável **ativo**; e-mail inexistente, senha incorreta ou usuário inativo retornam `401 BAD_CREDENTIALS`. | Mensagem única e genérica ("E-mail ou senha inválidos"), sem revelar qual campo está errado nem se o usuário está inativo. |
| AUTH-05 | Autocadastro (`POST /api/auth/register`) é público; `name` obrigatório (máx. 255), `email` válido e único, `password` com 6 a 100 caracteres, `active` opcional (padrão `true`). | Validação no cliente espelhando essas regras; `409 DUPLICATE_EMAIL` exibido junto ao campo de e-mail; `400 VALIDATION_ERROR` exibe `details`. |
| AUTH-06 | Senha é armazenada com BCrypt e **nunca** retornada pela API (RN-007). | O frontend nunca persiste, registra em log ou exibe a senha; o campo é mascarado e descartado após o envio. |
| AUTH-07 | Autenticação é stateless; não há RBAC no MVP (`docs/arquitetura.md`). | Qualquer responsável autenticado pode executar todas as ações protegidas; não criar perfis/permissões no cliente. |
| AUTH-08 | `401 UNAUTHORIZED` indica token ausente, inválido ou expirado (`docs/arquitetura.md` §3.2 e §5.4). | Limpar sessão persistida, remover token do `ApiClient`, informar "Sessão expirada" e redirecionar ao login. |
| AUTH-09 | Exclusão física é proibida (`DELETE` → `405`). | O fluxo de autenticação não expõe exclusão de conta; inativação segue pelo cadastro de responsáveis. |

Restrições adicionais:

- Widgets não chamam HTTP diretamente; consomem `AuthRepository` (já existente — SPEC-014) por meio de um controlador de sessão.
- O token não deve ser exibido na UI nem registrado em logs.
- A tela não deve simular sucesso antes da resposta do servidor; botões ficam desabilitados com indicador de progresso durante o envio.
- Conforme a Regra 05, o desenvolvimento deve se basear exclusivamente em `docs/api.md`, `docs/arquitetura.md`, `docs/modelo-de-dados.md` e nesta SPEC.

## 4. Contratos e decisões técnicas

### 4.1. Endpoints

| Operação | Endpoint | Request | Sucesso | Erros |
|---|---|---|---|---|
| Login | `POST /api/auth/login` | `{ email, password }` | `200` → `{ token, responsible }` | `400 VALIDATION_ERROR`, `401 BAD_CREDENTIALS` |
| Autocadastro | `POST /api/auth/register` | `{ name, email, password, active? }` | `201` → dados do responsável (sem senha) | `400 VALIDATION_ERROR`, `409 DUPLICATE_EMAIL` |

### 4.2. Reaproveitamento da camada existente (SPEC-014)

- `AuthRepository` / `AuthRepositoryImpl` (`login`, `register`, `logout`, `isAuthenticated`, `currentToken`).
- `LoginRequest`, `LoginResponse`, `RegisterRequest`, `AuthSession`.
- `ApiClient.setAuthToken` / `clearAuthToken` e `ApiException.isUnauthorized`.

### 4.3. Novos componentes e interfaces de UI

- `AuthSessionController` (`ChangeNotifier`): estado `unknown` → `unauthenticated` / `authenticated`; expõe `session`, `login`, `register`, `logout`, `initialize` e `handleUnauthorized`.
- `AuthSessionStorage` (contrato) + `SecureAuthSessionStorage` (`flutter_secure_storage`) e `InMemoryAuthSessionStorage` (testes).
- Interceptação de `401`: `ApiClient` notifica o callback `onUnauthorized` registrado pelo `AuthSessionController`; não aplicável ao `401 BAD_CREDENTIALS` do próprio formulário de login.
- `AuthGuard` / helper `requireAuth(context)` que, sem sessão, abre o login e retorna `true` somente após autenticação bem-sucedida.
- Rotas nomeadas: `AppRoutes.login` (`/login`) e `AppRoutes.register` (`/register`).
- `AppScaffold`:
  - Botão de **Login** em destaque no canto superior direito do AppBar (`key: auth-login-button`).
  - Menu de perfil do usuário (`key: auth-user-menu`) com nome, e-mail e ação "Sair" (`logout`) quando autenticado.
- Chaves semânticas de teste (Keys):
  - Formulário de Login: `login-email-input`, `login-password-input`, `login-toggle-password-button`, `login-submit-button`, `login-to-register-button`, `login-error-banner`.
  - Formulário de Cadastro: `register-name-input`, `register-email-input`, `register-password-input`, `register-confirm-password-input`, `register-submit-button`, `register-error-banner`.
  - Cabeçalho global: `auth-login-button`, `auth-user-menu`.

### 4.4. Fluxo pós-autocadastro

Como o contrato documenta resposta `201` com os dados do responsável (sem token), após o cadastro o app deve executar login automático com as mesmas credenciais informadas; em caso de falha, redirecionar ao login com e-mail pré-preenchido.

## 5. Critérios de aceitação

- [x] Usuário anônimo navega por listagens e detalhes sem ser obrigado a logar.
- [x] Login válido armazena sessão, injeta Bearer no `ApiClient` e exibe o usuário autenticado.
- [x] Credenciais inválidas ou usuário inativo exibem mensagem genérica sem detalhar a causa.
- [x] Autocadastro valida campos no cliente, trata `409 DUPLICATE_EMAIL` e autentica o usuário ao concluir.
- [x] Ações de mutação e operações de anexos exigem login e retomam a ação após autenticação.
- [x] Sessão é restaurada ao reiniciar o app.
- [x] Logout remove token do `ApiClient` e da persistência local.
- [x] Qualquer `401 UNAUTHORIZED` fora do login encerra a sessão e redireciona ao login com aviso.
- [x] Senha e token nunca são exibidos nem registrados em logs.

## 6. Cenários de teste

- **Sucesso:** login válido → sessão autenticada e header `Authorization` presente nas chamadas protegidas; autocadastro válido → login automático.
- **Validação:** e-mail em formato inválido, senha com menos de 6 ou mais de 100 caracteres, nome vazio, confirmação de senha divergente → envio bloqueado com mensagens nos campos.
- **Credenciais:** `401 BAD_CREDENTIALS` → mensagem genérica, sessão permanece anônima.
- **Conflito:** `409 DUPLICATE_EMAIL` no cadastro → erro associado ao campo de e-mail.
- **Sessão expirada:** requisição protegida retorna `401 UNAUTHORIZED` → sessão limpa, redirecionamento ao login, aviso exibido.
- **Restauração:** sessão persistida é carregada na inicialização e reinjetada no `ApiClient`.
- **Guard:** usuário anônimo aciona "Nova Empresa"/"Nova Obrigação"/upload de anexo → abre login; após autenticar, retoma a ação.
- **Falha de dependência:** API indisponível no login → `NETWORK_ERROR` com opção de tentar novamente.
- **Regressão:** listagens anônimas (SPEC-015/016) continuam funcionando sem token.

## 7. Dependências

- SPEC-013 (estrutura e navegação do Flutter).
- SPEC-014 (camada de integração com API — `AuthRepository`, DTOs, `ApiClient`).
- Contratos REST em `docs/api.md` (*Autenticação e Autorização (JWT)* e *Endpoints de Autenticação*).
- Diretrizes de integração em `docs/arquitetura.md` §3.2.
- Impacta: SPEC-016, SPEC-017, SPEC-018, SPEC-020, SPEC-021 e SPEC-022 (ações protegidas).

## 8. Pendências e pontos a confirmar

- **Expiração do token:** a documentação não informa o tempo de validade do JWT nem se a resposta do login inclui `expiresAt`. Até definição, a expiração é detectada apenas via `401`.
- **Refresh token:** não há endpoint de renovação documentado; não implementar refresh sem contrato.
- **Armazenamento seguro:** definir o pacote de persistência (ex.: `flutter_secure_storage` para mobile/desktop; no Flutter Web não há armazenamento equivalente seguro). Requer decisão antes da implementação.
- **Autocadastro com token:** `docs/api.md` (seção Swagger) sugere obter token "via login (ou register)", mas o contrato de `POST /api/auth/register` descreve apenas dados do responsável. Confirmar se o registro retorna token; esta SPEC assume que **não** retorna.
- **Logout no servidor:** não há endpoint de logout/revogação documentado; o logout é apenas local.
- **Exigir login para todo o app?** O backend permite leitura anônima; esta SPEC mantém a leitura anônima. Confirmar se o produto deseja tornar o app inteiramente autenticado.

## 9. Rastreabilidade

- Origem: regras de autenticação documentadas do backend (`docs/api.md`, `docs/arquitetura.md`).
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/arquitetura.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md` e `docs/CHANGELOG.md`.

