# API REST

Documentação formal dos endpoints expostos pela API da aplicação **Player Contabilidade Back**.

---

## Convenções, Segurança e Tratamento de Erros

### Autenticação e Autorização (JWT)
- **Operações Anônimas (`GET`):** Todos os endpoints de leitura (`GET /api/**`) estão abertos para consulta sem necessidade de autenticação.
- **Operações Restritas (`POST`, `PUT`):** Endpoints de criação e alteração (`POST /api/**`, `PUT /api/**`, exceto `POST /api/auth/login`) exigem o cabeçalho `Authorization: Bearer <token-jwt>`. Requisições não autenticadas resultam em `401 Unauthorized`.
- **Exclusão Física:** Operações de exclusão física (`DELETE /api/**`) são proibidas por arquitetura e retornam `405 Method Not Allowed`. O encerramento de ciclos é feito por inativação lógica via `PUT` (`active: false`).

As respostas de erro seguem o padrão padronizado com corpo JSON contendo `code`, `message` e detalhes opcionais:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Dados da requisição inválidos",
  "details": ["legalName: Razão social é obrigatória"],
  "timestamp": "2026-11-08T12:00:00"
}
```

| HTTP | Código (`code`) | Significado |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Dados da requisição inválidos (Bean Validation ou formato incorreto) |
| 401 | `UNAUTHORIZED` / `BAD_CREDENTIALS` | Token ausente/inválido ou credenciais incorretas |
| 404 | `NOT_FOUND` | Recurso solicitado não foi encontrado pelo identificador |
| 409 | `DUPLICATE_CNPJ` | Conflito por tentativa de cadastrar ou alterar para CNPJ já existente |
| 409 | `DUPLICATE_EMAIL` | Conflito por tentativa de cadastrar ou alterar para e-mail já existente |
| 405 | — | Método HTTP não permitido (ex.: tentativa de `DELETE` físico) |

---

## Endpoints de Autenticação (`/api/auth`)

### POST /api/auth/register
Realiza o autocadastro / registro de um novo usuário responsável sem necessidade de autenticação prévia. O hash da senha (`BCrypt`) é gravado de forma segura e nunca retornado na resposta.

**Request**
```json
{
  "name": "Carlos Silva",
  "email": "carlos@empresa.com",
  "password": "senhaSegura123",
  "active": true
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `name` | String | Sim | Nome completo do responsável (máx. 255) |
| `email` | String | Sim | E-mail corporativo único |
| `password` | String | Sim | Senha inicial (mínimo 6, máximo 100 caracteres) |
| `active` | Boolean | Não | Situação cadastral inicial (padrão `true`) |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 201 | — | Usuário registrado com sucesso |
| 400 | `VALIDATION_ERROR` | Nome vazio, e-mail inválido ou senha menor que 6 caracteres |
| 409 | `DUPLICATE_EMAIL` | E-mail já utilizado por outro usuário |

---

### POST /api/auth/login
Realiza a autenticação de um usuário responsável ativo e emite um token JWT (Bearer).

**Request**
```json
{
  "email": "carlos@empresa.com",
  "password": "senhaSegura123"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `email` | String | Sim | E-mail corporativo cadastrado |
| `password` | String | Sim | Senha em texto claro para conferência |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Autenticação efetuada com sucesso, retorna token Bearer e dados do usuário |
| 400 | `VALIDATION_ERROR` | Formato de e-mail inválido ou campos vazios |
| 401 | `BAD_CREDENTIALS` | E-mail inexistente, senha incorreta ou usuário inativo |

---

## Endpoints de Responsáveis (`/api/responsibles`)

### POST /api/responsibles
Cadastra um novo usuário responsável. Requer autenticação JWT (`Authorization: Bearer <token>`). O hash da senha (`BCrypt`) é gravado de forma segura e nunca retornado na resposta.

**Request**
```json
{
  "name": "Carlos Silva",
  "email": "carlos@empresa.com",
  "password": "senhaSegura123",
  "active": true
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `name` | String | Sim | Nome completo do responsável (máx. 255) |
| `email` | String | Sim | E-mail corporativo único |
| `password` | String | Sim | Senha inicial (mínimo 6, máximo 100 caracteres) |
| `active` | Boolean | Não | Situação cadastral inicial (padrão `true`) |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 201 | — | Responsável cadastrado com sucesso |
| 400 | `VALIDATION_ERROR` | Nome vazio, e-mail inválido ou senha menor que 6 caracteres |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 409 | `DUPLICATE_EMAIL` | E-mail já utilizado por outro usuário |

---

### GET /api/responsibles
Lista responsáveis cadastrados com suporte a paginação e filtro por situação cadastral. Aberto para acesso anônimo.

**Parâmetros de Query**
| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `active` | Boolean | opcional | Se informado, filtra ativos (`true`) ou inativos (`false`) |
| `page` | Integer | `0` | Número da página (base zero) |
| `size` | Integer | `20` | Quantidade de registros por página |
| `sort` | String | `id,asc` | Ordenação dos resultados |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Listagem paginada retornada com sucesso |

---

### GET /api/responsibles/{id}
Recupera os detalhes de um responsável pelo ID. Aberto para acesso anônimo. A senha nunca é exposta.

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Responsável encontrado |
| 404 | `NOT_FOUND` | Identificador não existe |

---

### PUT /api/responsibles/{id}
Atualiza os dados de um responsável (nome, e-mail e situação cadastral / inativação lógica). Requer autenticação JWT.

**Request**
```json
{
  "name": "Carlos Silva Atualizado",
  "email": "carlos.silva@empresa.com",
  "active": false
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `name` | String | Sim | Nome completo |
| `email` | String | Sim | E-mail válido e único |
| `active` | Boolean | Sim | Situação cadastral (`false` para soft delete) |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Responsável atualizado com sucesso |
| 400 | `VALIDATION_ERROR` | Campos obrigatórios ausentes |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 404 | `NOT_FOUND` | Identificador informado não existe |
| 409 | `DUPLICATE_EMAIL` | Novo e-mail já pertence a outro usuário |

---

## Endpoints de Empresas (`/api/companies`)

### POST /api/companies
Cadastra uma nova empresa cliente. O CNPJ é normalizado e validado através dos dígitos verificadores. Requer autenticação JWT (`Authorization: Bearer <token>`).

**Request**
```json
{
  "legalName": "Petróleo Brasileiro S.A.",
  "tradeName": "Petrobras",
  "cnpj": "33.000.167/0001-01",
  "active": true
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `legalName` | String | Sim | Razão social (máx. 255 caracteres) |
| `tradeName` | String | Não | Nome fantasia (máx. 255 caracteres) |
| `cnpj` | String | Sim | CNPJ formatado ou apenas dígitos (validado) |
| `active` | Boolean | Não | Situação cadastral inicial (padrão `true`) |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 201 | — | Empresa criada com sucesso |
| 400 | `VALIDATION_ERROR` | Falha de validação (CNPJ inválido, razão social vazia) |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 409 | `DUPLICATE_CNPJ` | CNPJ já pertence a outra empresa |

---

### GET /api/companies
Lista empresas cadastradas com suporte a paginação e filtro por situação cadastral. Aberto para acesso anônimo.

**Parâmetros de Query**
| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `active` | Boolean | opcional | Se informado, filtra apenas ativas (`true`) ou inativas (`false`) |
| `page` | Integer | `0` | Número da página (base zero) |
| `size` | Integer | `20` | Quantidade de registros por página |
| `sort` | String | `id,asc` | Ordenação dos resultados |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Listagem paginada retornada com sucesso |

---

### GET /api/companies/{id}
Recupera os detalhes de uma empresa a partir do seu identificador numérico. Aberto para acesso anônimo.

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Empresa encontrada |
| 404 | `NOT_FOUND` | Identificador não existe no banco de dados |

---

### PUT /api/companies/{id}
Atualiza os dados de uma empresa existente, incluindo razão social, nome fantasia, CNPJ e situação cadastral (ativação/inativação). Requer autenticação JWT (`Authorization: Bearer <token>`).

**Request**
```json
{
  "legalName": "Petróleo Brasileiro S.A. - Em Recuperação",
  "tradeName": "Petrobras Nova",
  "cnpj": "33.000.167/0001-01",
  "active": false
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `legalName` | String | Sim | Razão social |
| `tradeName` | String | Não | Nome fantasia |
| `cnpj` | String | Sim | CNPJ válido (não pode conflitar com outra empresa) |
| `active` | Boolean | Sim | Situação cadastral (`true` para ativa, `false` para inativa) |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Empresa atualizada com sucesso |
| 400 | `VALIDATION_ERROR` | Dados inválidos ou campos obrigatórios ausentes |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 404 | `NOT_FOUND` | Identificador informado não existe |
| 409 | `DUPLICATE_CNPJ` | CNPJ alterado pertence a outra empresa |
