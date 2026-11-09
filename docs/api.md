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
| 422 | `COMPANY_INACTIVE` / `USER_INACTIVE` | Violação de regra de negócio RN-006 (atribuição para empresa ou responsável inativo) |
| 422 | `INVALID_STATUS_TRANSITION` | Violação do ciclo de vida de status da obrigação RN-008 |
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

---

## Endpoints de Obrigações Fiscais (`/api/obligations`)

### POST /api/obligations
Cria uma nova obrigação tributária para uma empresa e responsável especificados.
- Valida a existência e a situação cadastral ativa de ambos (`RN-006`).
- Define automaticamente o status inicial como `PENDING` no servidor.
- Registra a data de criação (`createdAt`) automaticamente.
- Requer autenticação JWT (`Authorization: Bearer <token>`).

**Request**
```json
{
  "companyId": 1,
  "responsibleId": 2,
  "title": "Declaração de Débitos e Créditos Tributários Federais",
  "description": "DCTF mensal referente ao período de apuração anterior",
  "dueDate": "2026-11-30"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `companyId` | Long | Sim | Identificador da empresa contratante (deve existir e estar ativa) |
| `responsibleId` | Long | Sim | Identificador do usuário responsável (deve existir e estar ativo) |
| `title` | String | Sim | Título ou nome da obrigação (máx. 255 caracteres) |
| `description` | String | Não | Detalhamento ou instruções complementares |
| `dueDate` | String (`YYYY-MM-DD`) | Sim | Prazo limite de entrega/conclusão |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 201 | — | Obrigação cadastrada com sucesso |
| 400 | `VALIDATION_ERROR` | Falha de validação nos campos da requisição |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 404 | `NOT_FOUND` | Empresa ou responsável não encontrado |
| 422 | `COMPANY_INACTIVE` / `USER_INACTIVE` | Empresa ou responsável inativo (RN-006) |

---

### GET /api/obligations
Lista obrigações cadastradas com suporte a paginação e filtros opcionais por empresa, responsável e status.
Para cada obrigação, retorna os dados necessários para exibição: empresa (`id`, `legalName`, `tradeName`, `cnpj`, `active`), responsável (`id`, `name`, `email`, `active`), status, quantidade de anexos (`attachmentCount`) e data de criação (`createdAt`).
Acesso anônimo permitido.

**Parâmetros de Query**
| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `companyId` | Long | opcional | Filtra obrigações vinculadas a uma empresa específica |
| `responsibleId` | Long | opcional | Filtra obrigações atribuídas a um responsável específico |
| `status` | ObligationStatus (`PENDING`, `IN_PROGRESS`, `COMPLETED`) | opcional | Filtra por status atual |
| `page` | Integer | `0` | Número da página (base zero) |
| `size` | Integer | `20` | Quantidade de registros por página |
| `sort` | String | `dueDate,asc` | Critério de ordenação |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Listagem paginada retornada com sucesso |

---

### GET /api/obligations/{id}
Recupera os detalhes completos de uma obrigação tributária a partir do seu identificador numérico, incluindo dados da empresa, do responsável, quantidade de anexos, data de criação e data de conclusão (`completedAt`), se houver.
Acesso anônimo permitido.

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Obrigação encontrada |
| 404 | `NOT_FOUND` | Identificador não existe no banco de dados |

---

### PUT /api/obligations/{id}
Atualiza os dados de uma obrigação existente.
- Permite alterar título, descrição, prazo (`dueDate`), e opcionalmente realizar transição de status (`RN-008`).
- Permite reatribuir empresa ou responsável. Caso alterados, valida se o novo destinatário está ativo (`RN-006`).
- Se o status for alterado para `COMPLETED`, registra a data/hora de conclusão (`completedAt`).
- Transições de status são validadas de acordo com a máquina de estados (`RN-008`): `PENDING` -> `IN_PROGRESS` / `COMPLETED`, `IN_PROGRESS` -> `COMPLETED`. Transições regressivas ou modificação de obrigações já concluídas resultam em erro 422.
- Requer autenticação JWT (`Authorization: Bearer <token>`).

**Request**
```json
{
  "companyId": 1,
  "responsibleId": 2,
  "title": "Declaração de Débitos e Créditos Tributários Federais - Retificadora",
  "description": "Retificação referente ao período anterior",
  "dueDate": "2026-12-05",
  "status": "IN_PROGRESS"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `companyId` | Long | Sim | Identificador da empresa vinculada |
| `responsibleId` | Long | Sim | Identificador do responsável atribuído |
| `title` | String | Sim | Título da obrigação (máx. 255 caracteres) |
| `description` | String | Não | Descrição da obrigação |
| `dueDate` | String (`YYYY-MM-DD`) | Sim | Prazo de entrega |
| `status` | ObligationStatus | Não | Novo status desejado (se nulo, mantém o status atual) |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Obrigação atualizada com sucesso |
| 400 | `VALIDATION_ERROR` | Falha de validação ou campos obrigatórios ausentes |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 404 | `NOT_FOUND` | Obrigação, empresa ou responsável não encontrado |
| 422 | `COMPANY_INACTIVE` / `USER_INACTIVE` | Nova empresa ou responsável está inativo (RN-006) |
| 422 | `INVALID_STATUS_TRANSITION` | Transição de status proibida pelo ciclo de vida (RN-008) |

---

### PATCH /api/obligations/{id}/status
Operação explícita para transição de status da obrigação fiscal.
- Segue a máquina de estados estrita do domínio (`RN-008`):
  - `PENDING` -> `IN_PROGRESS`
  - `IN_PROGRESS` -> `COMPLETED`
- Bloqueia saltos (ex.: `PENDING -> COMPLETED`).
- Bloqueia regressões (ex.: `IN_PROGRESS -> PENDING`, `COMPLETED -> IN_PROGRESS`, `COMPLETED -> PENDING`).
- Bloqueia qualquer alteração a partir de `COMPLETED` (estado terminal).
- Bloqueia transições para o mesmo status (operação não-idempotente).
- Ao atingir o status `COMPLETED`, preenche automaticamente a data de conclusão (`completedAt`). Em qualquer transição rejeitada, o estado e `completedAt` permanecem intocados.
- Requer autenticação JWT (`Authorization: Bearer <token>`).

**Request**
```json
{
  "status": "IN_PROGRESS"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|:---:|---|
| `status` | ObligationStatus (`IN_PROGRESS`, `COMPLETED`) | Sim | Novo status desejado para a obrigação |

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Status atualizado com sucesso |
| 400 | `VALIDATION_ERROR` | Status nulo ou formato enum inválido |
| 401 | `UNAUTHORIZED` | Requisição sem token JWT válido |
| 404 | `NOT_FOUND` | Obrigação informada não foi encontrada |
| 422 | `INVALID_STATUS_TRANSITION` | Transição de status proibida pelo ciclo de vida (RN-008) |
