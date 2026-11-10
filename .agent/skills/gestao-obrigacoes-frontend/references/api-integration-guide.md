# Guia de Integração com a API REST (Frontend)

Este documento orienta o consumo dos endpoints da API REST a partir do cliente Flutter, cobrindo segurança JWT, tratamento de exceções, paginação, upload/download e regras de desserialização segura.

---

## 1. Fonte da Verdade e Regra 05

Conforme a **Regra 05**, o frontend deve ser desenvolvido como consumidor de um serviço externo. **NUNCA** consulte o código Java do backend (`backend/src/**`).
A fonte oficial de todos os contratos é:
- `docs/api.md` (rotas, verbos, payloads, query parameters e respostas de erro).
- `docs/arquitetura.md` (diretrizes de segurança e convenções REST).

---

## 2. Cliente HTTP (`ApiClient`)

O `ApiClient` centraliza todas as requisições HTTP:
- **Base URL:** Obtida dinamicamente do `AppConfig.apiUrl` (configurável via `--dart-define=API_URL=...`).
- **Cabeçalhos Padrão:** `Content-Type: application/json` e `Accept: application/json`.
- **Autenticação:** Injeta automaticamente `Authorization: Bearer <token>` quando o token estiver presente.
- **Hook de Não Autorizado (`onUnauthorized`):** Callback disparado quando uma requisição autenticada recebe HTTP 401 do servidor, permitindo que o `AuthSessionController` encerre a sessão local de forma graciosa.

---

## 3. Tratamento Padronizado de Exceções (`ApiException`)

Todas as falhas retornadas pela API seguem o envelope de erro padronizado:
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Dados da requisição inválidos",
  "details": ["name: Nome é obrigatório"],
  "timestamp": "2026-11-10T12:00:00"
}
```

O `ApiException` expõe propriedades semânticas:
- `e.statusCode`: Código HTTP retornado (400, 401, 404, 409, 422, 500).
- `e.code`: Código de erro de negócio (`VALIDATION_ERROR`, `BAD_CREDENTIALS`, `DUPLICATE_CNPJ`, `DUPLICATE_EMAIL`, `COMPANY_INACTIVE`, `USER_INACTIVE`, `INVALID_STATUS_TRANSITION`, `STORAGE_ERROR`).
- `e.message`: Mensagem descritiva enviada pelo backend.
- `e.details`: Lista de mensagens de detalhamento de campos inválidos.

### Mapeamento Amigável na UI:
| Código / Status | Causa | Comportamento na UI |
|---|---|---|
| `401 BAD_CREDENTIALS` | Login com e-mail/senha incorretos ou inativo | Exibir *"E-mail ou senha inválidos."* (AUTH-04) |
| `401 UNAUTHORIZED` | Token JWT ausente ou expirado em operação protegida | Limpar sessão e solicitar login com *"Sessão expirada"* |
| `409 DUPLICATE_CNPJ` | Tentativa de cadastrar CNPJ já existente | Vincular mensagem ao campo de CNPJ |
| `409 DUPLICATE_EMAIL` | Tentativa de cadastrar e-mail já existente | Vincular mensagem ao campo de e-mail |
| `422 COMPANY_INACTIVE` | Tentativa de vincular empresa inativa | Informar que a empresa selecionada não está ativa |
| `422 USER_INACTIVE` | Tentativa de vincular responsável inativo | Informar que o responsável selecionado não está ativo |
| `422 INVALID_STATUS_TRANSITION`| Tentativa de salto ou regressão de status | Informar que a transição de status não é permitida |

---

## 4. Paginação do Spring Data (`PageResponse<T>`)

Endpoints de listagem (`GET /api/companies`, `GET /api/responsibles`, `GET /api/obligations`) retornam paginação no formato do Spring Data JPA:
- Parâmetros de consulta: `page` (base 0), `size` (padrão 20), `sort` (ex.: `id,asc` ou `dueDate,asc`).
- No Flutter, o consumo é encapsulado em `PageResponse<T>` contendo `content: List<T>`, `totalElements: int`, `totalPages: int`, `number: int` (página atual) e `empty: bool`.

---

## 5. Resiliência e Desserialização Segura

Para garantir robustez contra variações e plataformas (Web, Desktop, Mobile):
1. **Identificadores Numéricos:** Sempre use `(json['id'] as num).toInt()` em vez de `json['id'] as int`.
2. **Payloads de Autenticação:** `LoginResponse.fromJson` deve aceitar de forma tolerante tanto a chave `user` quanto `responsible`, e `token` ou `accessToken`.
3. **Datas e Horários:**
   - Datas fiscais sem horário (`dueDate`): parseadas para `DateTime`.
   - Timestamps (`createdAt`, `updatedAt`, `completedAt`): sempre usar `DateTime.tryParse(...)`.
4. **Strings e Nulos:** Prover valores padrão vazios (`?? ''`) ou boleanos seguros (`?? true`) para campos opcionais.

---

## 6. Autenticação, Persistência e Proteção de Rotas

1. **Leitura Anônima (AUTH-01):**
   - Listagens e consultas de detalhes funcionam sem necessidade de autenticação.
   - O app nunca força login na inicialização.
2. **Operações Protegidas (AUTH-02 e AUTH-03):**
   - Mutações (criação e edição de empresas, responsáveis e obrigações, transição de status) e todas as operações de anexos exigem login prévio.
   - Utilizar o helper `requireAuth(context, authController: ...)` para interceptar a ação de forma suave: se o usuário estiver desautenticado, abre a tela de login; após login com sucesso, retoma a operação pretendida.
3. **Persistência Segura (`AuthSessionStorage`):**
   - Em produção: `SecureAuthSessionStorage` utiliza `flutter_secure_storage`.
   - Em testes: `InMemoryAuthSessionStorage` evita dependências de canais de plataforma nativos.

