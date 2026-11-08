# API REST

Documentação formal dos endpoints expostos pela API da aplicação **Player Contabilidade Back**.

---

## Convenções e Tratamento de Erros

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
| 404 | `NOT_FOUND` | Recurso solicitado não foi encontrado pelo identificador |
| 409 | `DUPLICATE_CNPJ` | Conflito por tentativa de cadastrar ou alterar para CNPJ já existente |
| 422 | `COMPANY_INACTIVE` / `USER_INACTIVE` | Regra de negócio violada por inativação |
| 405 | — | Método HTTP não permitido (ex.: tentativa de `DELETE` físico) |

---

## Endpoints de Empresas (`/api/companies`)

### POST /api/companies
Cadastra uma nova empresa cliente. O CNPJ é normalizado e validado através dos dígitos verificadores.

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
| 409 | `DUPLICATE_CNPJ` | CNPJ já pertence a outra empresa |

---

### GET /api/companies
Lista empresas cadastradas com suporte a paginação e filtro por situação cadastral.

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
Recupera os detalhes de uma empresa a partir do seu identificador numérico.

**Respostas**
| HTTP | code | Quando |
|---|---|---|
| 200 | — | Empresa encontrada |
| 404 | `NOT_FOUND` | Identificador não existe no banco de dados |

---

### PUT /api/companies/{id}
Atualiza os dados de uma empresa existente, incluindo razão social, nome fantasia, CNPJ e situação cadastral (ativação/inativação).

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
| 404 | `NOT_FOUND` | Identificador informado não existe |
| 409 | `DUPLICATE_CNPJ` | CNPJ alterado pertence a outra empresa |

