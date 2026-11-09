# Player Contabilidade

Sistema completo para gerenciamento de obrigações contábeis e fiscais, empresas clientes, responsáveis e controle de prazos e anexos comprobatórios.

---

## Estrutura do Repositório

O projeto adota estrutura monorepo separando claramente as responsabilidades de backend, frontend e documentação técnica unificada:

```text
├── backend/            # API REST em Java 21, Spring Boot, MySQL e Flyway
├── frontend/           # Aplicação frontend em Flutter (Web, Desktop, Mobile)
├── docs/               # Documentação técnica compartilhada, contratos de API e modelos
├── .agent/             # Regras, especificações (SPECs) e skills de desenvolvimento
├── docker-compose.yml  # Orquestração de serviços de infraestrutura (MySQL)
└── README.md           # Guia geral do projeto
```

---

## Funcionalidades Implementadas (Backend)

- **Autenticação e Segurança (JWT):** Autenticação stateless via `POST /api/auth/login` e autocadastro público em `POST /api/auth/register`, emitindo tokens Bearer JWT com senhas protegidas via `BCrypt`.
- **API de Empresas (`/api/companies`):** Cadastro com validação estrita de dígitos verificadores de CNPJ e unicidade, listagem paginada com filtro por situação (`active`), busca por identificador e inativação lógica (*soft delete*).
- **API de Responsáveis (`/api/responsibles`):** Gestão de responsáveis contábeis com e-mail único, listagem paginada com filtros e inativação lógica. Senhas nunca são expostas em DTOs.
- **API de Obrigações Fiscais (`/api/obligations`):** Cadastro de obrigações fiscais vinculando obrigatoriamente empresa e responsável ativos (RN-006). Toda obrigação nasce no status inicial `PENDING`. Listagem com filtros combináveis (`companyId`, `responsibleId`, `status`, intervalo de `dueDate`) e busca detalhada.
- **Máquina de Estados de Obrigações (RN-008):** Transição controlada via `PATCH /api/obligations/{id}/status`:
  - `PENDING -> IN_PROGRESS`
  - `IN_PROGRESS -> COMPLETED` (preenchimento automático de `completed_at`)
  - Bloqueio estrito de saltos, regressões e reabertura a partir de `COMPLETED` (estado terminal).
- **API de Anexos (`/api/obligations/{id}/attachments` e `/api/attachments/{id}/download`):** Upload multipart (`multipart/form-data`) de comprovantes fiscais com validação de arquivo, armazenamento local seguro (`storage.location`) com proteção contra *Path Traversal*, metadados persistidos no MySQL e mecanismo de compensação em caso de erro no banco.
- **Sem Exclusão Física (ADR-0001):** Repositórios e controladores não expõem métodos `delete*`; tentativas de `DELETE` HTTP retornam `405 Method Not Allowed`, preservando o histórico fiscal.
- **Documentação Interativa (OpenAPI 3 / Swagger UI):** Interface gráfica com suporte completo a autenticação Bearer JWT via botão **Authorize**.
- **Cobertura de Testes (JaCoCo):** Relatórios automáticos de cobertura de código com mais de 86% de cobertura de linhas geral e 100% nos controllers.

---

## Stack Tecnológica

- **Linguagem:** Java 21 LTS
- **Framework:** Spring Boot 3.x / 4.x (WebMvc, Data JPA, Security, Validation)
- **Segurança:** JJWT (`io.jsonwebtoken` 0.12.6) e `BCryptPasswordEncoder`
- **Banco de Dados:** MySQL 8.0 com migrações gerenciadas pelo Flyway
- **Documentação de API:** SpringDoc OpenAPI 2.8.5 (Swagger UI 3.0)
- **Métricas de Qualidade:** JaCoCo 0.8.12
- **Testes Automatizados:** JUnit 5, Mockito, Spring Test e Testcontainers (MySQL 8)

---

## Arquitetura do Sistema

A aplicação adota uma organização em camadas combinada com o padrão **Package by Feature** no backend e uma estrutura **Feature-First / Clean Architecture** no frontend Flutter:

- **Backend:** Organizado em domínios (`auth`, `company`, `responsible`, `obligation`, `attachment`, `shared`) contendo camadas estritas (`controller`, `dto`, `service`, `entity`, `mapper`, `repository`, `storage`).
- **Frontend (Flutter):** Organizado por features (`features/<feature>/{data, domain, presentation}`) com camada `core` para roteamento, tema e cliente HTTP com interceptor JWT.

Consulte a especificação arquitetural completa em [`docs/arquitetura.md`](docs/arquitetura.md).

---

## Como Rodar o Projeto

### Pré-requisitos
- **JDK 21** instalado e configurado no PATH
- **Docker** e **Docker Compose** em execução
- **Git**

### 1. Configuração de Variáveis de Ambiente
Navegue até a pasta `backend/` e crie seu arquivo `.env` a partir do modelo fictício:
```bash
cd backend
cp .env.example .env
```

| Variável | Descrição | Valor Padrão / Exemplo |
|---|---|---|
| `DB_PORT` | Porta exposta pelo MySQL | `3306` |
| `DB_NAME` | Nome do banco de dados | `player_contabilidade` |
| `DB_USERNAME` | Usuário da aplicação no MySQL | `player_user` |
| `DB_PASSWORD` | Senha do usuário da aplicação | `player_secret_password` |
| `DB_ROOT_PASSWORD` | Senha de root do MySQL (container) | `player_root_password` |
| `DB_URL` | JDBC URL de conexão | `jdbc:mysql://localhost:3306/player_contabilidade?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true` |
| `JWT_SECRET` | Chave secreta HMAC-SHA (mín. 32 bytes) | `sua-chave-secreta-jwt-muito-longa-e-segura-32-bytes` |
| `JWT_EXPIRATION_MS`| Tempo de validade do token (ms) | `1800000` (30 minutos) |
| `STORAGE_LOCATION` | Diretório no disco para anexos | `uploads` |

### 2. Subir o Banco de Dados MySQL
Na raiz do projeto:
```bash
docker compose up -d
```

### 3. Executar o Backend
A partir do diretório `backend/`:
```bash
# Windows
.\mvnw.cmd spring-boot:run

# Linux / macOS
./mvnw spring-boot:run
```

### 4. Executar os Testes Automatizados (Backend)
```bash
# Windows
.\mvnw.cmd test

# Linux / macOS
./mvnw test
```

---

## Documentação Interativa com Swagger UI

Após iniciar a aplicação, acesse no navegador:
- **Swagger UI:** [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON:** [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)

### Como autenticar no Swagger UI:
1. Realize o login no endpoint `POST /api/auth/login` (ou crie um usuário em `POST /api/auth/register`).
2. Copie o valor do campo `token` retornado no JSON.
3. Clique no botão **Authorize** (cadeado verde no canto superior direito).
4. No campo **bearerAuth**, cole o token JWT e confirme.

---

## Relatório de Cobertura de Testes (JaCoCo)

Após rodar `mvn test`, o relatório de cobertura de código estará disponível em:
```text
target/site/jacoco/index.html
```

Para abri-lo no Windows (PowerShell):
```powershell
Start-Process "target/site/jacoco/index.html"
```

---

## Mapa da Documentação

A documentação detalhada do sistema está estruturada na pasta `docs/`:
- [Guia Central de Documentação](docs/index.md)
- [Arquitetura, Escopo do MVP e Convenções](docs/arquitetura.md)
- [Especificação da API REST](docs/api.md)
- [Modelo de Dados e Diagrama ER](docs/modelo-de-dados.md)
- [Status de Implementação das Regras e Cobertura](docs/status-implementacao.md)
- [Decisões Arquiteturais (ADRs)](docs/decisoes/ADR-0001-repositories-sem-operacoes-de-exclusao.md)
- [Pendências e Perguntas em Aberto](docs/pendencias-e-perguntas-em-aberto.md)
- [Changelog](docs/CHANGELOG.md)
