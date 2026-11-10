# Arquitetura, Escopo do MVP e Convenções

Documento formal de arquitetura da aplicação **Player Contabilidade** (Backend Spring Boot e Frontend Flutter), abrangendo os limites do MVP, organização de pacotes e camadas, estratégia de armazenamento de anexos e convenções de comunicação e dados.

---

## 1. Visão Geral e Limites do MVP

O sistema tem como objetivo gerenciar o cumprimento de obrigações contábeis e fiscais de empresas clientes por responsáveis contábeis, garantindo controle estrito de ciclo de vida de status, integridade referencial, preservação de histórico auditável (sem exclusão física) e armazenamento seguro de comprovantes anexos.

### 1.1. O que está DENTRO do Escopo do MVP
- **Empresas Clientes (`Company`):** Cadastro com validação estrita dos dois dígitos verificadores de CNPJ e unicidade; listagem paginada com filtro por situação (`active`); busca por ID; atualização de dados e inativação lógica (*soft delete*).
- **Responsáveis Contábeis (`Responsible` / `users`):** Autocadastro público (`POST /api/auth/register`) e cadastro interno autenticado; validação de e-mail único e formato; senhas criptografadas com `BCrypt` (nunca expostas em DTOs); inativação lógica.
- **Autenticação e Segurança (JWT):** Autenticação stateless via `POST /api/auth/login` gerando token Bearer JWT; interceptação com `JwtAuthenticationFilter`; endpoints de mutação protegidos e Swagger UI autenticado.
- **Obrigações Fiscais (`Obligation`):** Criação vinculada a empresa e responsável ativos (RN-006); toda obrigação nasce obrigatoriamente no status `PENDING`; listagem paginada com filtros combinados (`companyId`, `responsibleId`, `status`, intervalo de `dueDate`); detalhes com contagem de anexos.
- **Máquina de Estados de Obrigações (RN-008):** Transição estrita via `PATCH /api/obligations/{id}/status`:
  - `PENDING -> IN_PROGRESS`
  - `IN_PROGRESS -> COMPLETED` (preenche automaticamente `completed_at`)
  - Bloqueio rigoroso de saltos (`PENDING -> COMPLETED`), regressões (`IN_PROGRESS -> PENDING`) e reabertura a partir de `COMPLETED` (estado terminal).
- **Gerenciamento de Anexos (`Attachment`):** Upload multipart (`multipart/form-data`) protegido por JWT; listagem dos anexos da obrigação; download binário via streaming; armazenamento em filesystem local seguro (`LocalFileSystemStorage`) desacoplado via interface `FileStorage`; apenas metadados no MySQL; compensação com remoção do arquivo físico se a persistência no banco falhar.
- **Qualidade e Documentação:** Documentação interativa Swagger UI / OpenAPI 3.0 em `/swagger-ui.html` com suporte a `bearerAuth`; relatórios contínuos de cobertura de código com JaCoCo (`>86%` geral, `100%` em controllers); suíte de testes de integração com container real MySQL 8 via Testcontainers.

### 1.2. O que está FORA do Escopo do MVP
- **Exclusão Física (*Hard Delete*):** Nenhuma entidade de negócio pode ser fisicamente apagada (`DELETE` HTTP responde `405 Method Not Allowed`). A inativação usa flag booleana `active`.
- **RBAC Multi-perfil Complexo:** No MVP existe autenticação JWT única para responsáveis contábeis, sem granularidade de permissões por perfil (ex.: admin vs operador).
- **Recorrência Automática de Obrigações:** Não há rotinas agendadas (cron/jobs) gerando obrigações mensais ou anuais em lote; cada obrigação é criada individualmente.
- **Status Derivado "Atrasada":** O enum possui apenas `PENDING`, `IN_PROGRESS` e `COMPLETED`. Situações de atraso são calculadas dinamicamente na consulta comparando `dueDate` com a data atual.
- **OCR e Processamento de Imagens:** Não há extração automática de dados dos comprovantes anexados.
- **Multi-tenancy Dinâmico:** O banco e a infraestrutura operam como single-tenant no escopo do MVP.

---

## 2. Arquitetura do Backend (Spring Boot 3/4 + Java 21)

A arquitetura do backend adota a abordagem **Package by Feature** combinada com **Arquitetura em Camadas**, garantindo alta coesão e baixo acoplamento entre os domínios funcionais.

```
src/main/java/dmptsystem/.../playercontabilidadeback/
├── auth/                       # Autenticação e registro público de usuários
│   ├── controller/             # Endpoints /api/auth/login e /api/auth/register
│   ├── dto/                    # LoginRequest, LoginResponse
│   └── service/                # AuthService
├── company/                    # Domínio de Empresas clientes
│   ├── controller/             # CompanyController (/api/companies)
│   ├── dto/                    # CreateCompanyRequest, UpdateCompanyRequest, CompanyResponse, etc.
│   ├── entity/                 # Company (JPA)
│   ├── mapper/                 # CompanyMapper
│   ├── repository/             # CompanyRepository (sem métodos delete*)
│   └── service/                # CompanyService
├── responsible/                # Domínio de Responsáveis contábeis
│   ├── controller/             # ResponsibleController (/api/responsibles)
│   ├── dto/                    # CreateResponsibleRequest, UpdateResponsibleRequest, ResponsibleResponse
│   ├── entity/                 # Responsible (tabela física 'users')
│   ├── mapper/                 # ResponsibleMapper
│   ├── repository/             # ResponsibleRepository (sem métodos delete*)
│   └── service/                # ResponsibleService
├── obligation/                 # Domínio de Obrigações fiscais
│   ├── controller/             # ObligationController (/api/obligations)
│   ├── dto/                    # CreateObligationRequest, UpdateObligationRequest, Detail, ListItem
│   ├── entity/                 # Obligation (JPA, máquina de estados)
│   ├── enums/                  # ObligationStatus (PENDING, IN_PROGRESS, COMPLETED)
│   ├── exception/              # Exceções específicas do domínio
│   ├── mapper/                 # ObligationMapper
│   ├── repository/             # ObligationRepository (filtros otimizados e contagem de anexos)
│   └── service/                # ObligationService (regras RN-006 e RN-008)
├── attachment/                 # Domínio de Anexos comprobatórios
│   ├── controller/             # AttachmentController (upload, list, download)
│   ├── dto/                    # AttachmentResponse, DownloadedFile
│   ├── entity/                 # Attachment (metadados no MySQL)
│   ├── exception/              # StorageException, InvalidFileException
│   ├── mapper/                 # AttachmentMapper
│   ├── repository/             # AttachmentRepository
│   ├── service/                # AttachmentService (orquestrador com compensação)
│   └── storage/                # FileStorage, LocalFileSystemStorage
└── shared/                     # Componentes e utilitários transversais
    ├── config/                 # OpenApiConfig, WebConfig
    ├── exception/              # GlobalExceptionHandler, StandardError, BusinessException, NotFoundException
    ├── security/               # SecurityConfig, JwtService, JwtAuthenticationFilter, CustomUserDetailsService
    └── validator/              # Cnpj (validador de DV), ValidCnpj (anotação Bean Validation)
```

### 2.1. Responsabilidade das Camadas
1. **Controller:** Trata requisições HTTP, validação de entrada (`@Valid`), documentação OpenAPI (`@Operation`, `@Schema`) e retorno de status HTTP adequados. Não contém lógica de negócio.
2. **DTO:** Objetos imutáveis (`Java Record`) com Bean Validation para isolamento do contrato da API das entidades internas de banco.
3. **Service:** Concentra todas as regras de negócio, validações de integridade cruzada (ex.: RN-006 inatividade), orquestração transacional (`@Transactional`) e disparo de compensações.
4. **Entity / Enums:** Encapsula regras puras de domínio (ex.: validação de transição de status na entidade `Obligation` e enum `ObligationStatus`).
5. **Repository:** Extensões diretas de `org.springframework.data.repository.Repository` declarando apenas consultas e comandos estritamente necessários, sem expor operações de exclusão física (`delete*`), conforme a **ADR-0001**.
6. **Storage:** Abstração de infraestrutura para gravação de binários, garantindo isolamento através de chave única segura baseada em UUID, prevenção contra *Path Traversal* e facilidade para migração futura para S3/GCS.

---

## 3. Arquitetura do Frontend (Flutter)

O frontend em Flutter foi estruturado com base em **Feature-First** combinada com **Clean Architecture** (Data / Domain / Presentation), estabelecido na **SPEC-013** e servindo de base para o desenvolvimento das próximas especificações (SPECs 14 a 23).

```text
frontend/lib/
├── core/                       # Infraestrutura e utilitários transversais
│   ├── config/                 # AppConfig (ambientes dev/staging/prod e injeção dinâmica de Base URL)
│   ├── network/                # ApiClient (HTTP desacoplado) e ApiException (mapeamento de erros do backend)
│   ├── routing/                # AppRoutes (rotas nomeadas e injeção de dependências)
│   ├── theme/                  # AppTheme (paleta corporativa Material 3 e tipografia)
│   └── widgets/                # Widgets compartilhados (AppScaffold responsivo, Loading, Error, Empty)
├── features/                   # Módulos funcionais independentes (Clean Architecture)
│   ├── company/                # Domínio de Empresas Clientes
│   │   ├── data/               # CompanyRemoteDataSource, CompanyRepositoryImpl
│   │   ├── domain/             # Company (entidade), CompanyRepository (contrato)
│   │   └── presentation/       # CompanyListPage
│   ├── responsible/            # Domínio de Responsáveis Contábeis
│   │   ├── data/               # ResponsibleRemoteDataSource, ResponsibleRepositoryImpl
│   │   ├── domain/             # Responsible (entidade), ResponsibleRepository (contrato)
│   │   └── presentation/       # ResponsibleListPage
│   ├── obligation/             # Domínio de Obrigações Fiscais e Máquina de Estados
│   │   ├── data/               # ObligationRemoteDataSource, ObligationRepositoryImpl
│   │   ├── domain/             # Obligation (entidade com regras de transição), ObligationRepository
│   │   └── presentation/       # ObligationListPage (filtros combinados e chips de status)
│   ├── auth/                   # Autenticação e Registro (Data e Domain implementados)
│   │   ├── data/               # AuthRemoteDataSource, AuthRepositoryImpl, DTOs (Login/Register)
│   │   ├── domain/             # AuthSession (entidade), AuthRepository (contrato)
│   │   └── presentation/       # [Planejado - SPEC-015+] LoginPage, RegisterPage
│   └── attachment/             # Upload, Listagem e Download de Anexos (Data e Domain implementados)
│       ├── data/               # AttachmentRemoteDataSource, AttachmentRepositoryImpl
│       ├── domain/             # Attachment (entidade com sizeFormatted), AttachmentRepository
│       └── presentation/       # [Planejado - SPEC-021/022] AttachmentListWidget, UploadAttachmentDialog
└── main.dart                   # Inicialização da aplicação e bootstrap de configurações
```

### 3.1. Responsabilidade das Camadas no Frontend
1. **Data:** Responsável pela comunicação com a API REST (`RemoteDataSource`), mapeamento de payloads JSON e implementação dos contratos de repositório (`RepositoryImpl`).
2. **Domain:** Entidades de negócio puras (sem dependência de framework de UI ou pacotes de transporte) e contratos abstratos de repositório (`Repository`). Regras puras da interface, como validação de transições de status da obrigação, residem na entidade de domínio.
3. **Presentation:** Telas, formulários e componentes visuais. **Regra estrita:** a camada de apresentação nunca realiza chamadas HTTP diretamente, consumindo unicamente as abstrações de repositório/casos de uso.
4. **Core:** Componentes transversais reutilizáveis, incluindo layout responsivo adaptativo (`AppScaffold`), telas padronizadas para estados de `Loading`, `Error` e `Empty`, além de cliente HTTP (`ApiClient`) e tratamento de exceções (`ApiException`).

### 3.2. Diretrizes de Integração Frontend <-> Backend
- **Configuração de Base URL:** A URL da API nunca deve estar *hardcoded*. O `AppConfig` permite injeção via parâmetro `--dart-define=API_URL=...` ou variáveis de ambiente.
- **Armazenamento de Token:** O token JWT retornado no login deve ser gerenciado de forma segura e injetado via cabeçalho `Authorization: Bearer <token>` em todas as requisições autenticadas.
- **Tratamento de Erros:** O cliente HTTP traduz as respostas de erro para `ApiException`, mapeando os campos padronizados (`code`, `message`, `details`) definidos em [`docs/api.md`](api.md). Em caso de `401 Unauthorized`, a aplicação deve desautenticar o usuário e redirecionar para a tela de autenticação.

---

## 4. Estratégia de Armazenamento de Anexos

O armazenamento de arquivos atende à **RN-009**:
1. **Separação Física e Lógica:** O arquivo físico nunca é persistido como BLOB no MySQL. Apenas os metadados são gravados na tabela `attachment`:
   - `id`: Chave primária surrogate (`BIGINT`).
   - `obligation_id`: Chave estrangeira obrigatória vinculada a `obligation`.
   - `original_filename`: Nome original do arquivo enviado pelo usuário (para exibição e download).
   - `storage_key`: Identificador interno único gerado no formato `<uuid>_<sanitized_filename>`.
   - `content_type`: Tipo MIME do arquivo (ex.: `application/pdf`, `image/png`).
   - `size_bytes`: Tamanho em bytes do arquivo.
   - `uploaded_at`: Data e hora do envio.
2. **Proteção Contra Path Traversal:** O serviço de armazenamento normaliza o caminho e assegura que o arquivo resida estritamente dentro do diretório raiz configurado (`storage.location`). Qualquer tentativa de usar sequências `../` resulta em `StorageException`.
3. **Mecanismo de Compensação:** Se a persistência dos metadados no banco de dados falhar após o upload físico em disco, o serviço de aplicação executa imediatamente a exclusão do arquivo físico gravado, evitando arquivos órfãos no filesystem.

---

## 5. Convenções do Projeto

### 5.1. Padrões REST e JSON
- **URLs no Plural e Minúsculas:** `/api/companies`, `/api/responsibles`, `/api/obligations`, `/api/attachments`.
- **Verbos HTTP Semânticos:**
  - `GET`: Consulta ou listagem (idempotente).
  - `POST`: Criação de recursos ou operações de autenticação.
  - `PUT`: Substituição total ou atualização cadastral de um recurso.
  - `PATCH`: Modificação parcial ou avanço específico de estado (`/status`).
  - `DELETE`: Proibido em todas as rotas (retorna `405 Method Not Allowed`).
- **Formato de Dados:** Todos os payloads de requisição e resposta trafegam em JSON utilizando convenção `camelCase`.
- **Upload Multipart:** Requisições de upload utilizam `multipart/form-data` com o campo de arquivo nomeado como `file`.

### 5.2. Datas e Horários
- Datas fiscais sem horário (ex.: `dueDate`): Formato ISO-8601 `YYYY-MM-DD`.
- Timestamps de auditoria e conclusão (ex.: `createdAt`, `updatedAt`, `completedAt`, `uploadedAt`): Formato ISO-8601 estendido `YYYY-MM-DDTHH:mm:ss`.

### 5.3. Paginação e Ordenação
- Padrão Spring Data: parâmetros de consulta `page` (iniciando em 0), `size` (tamanho da página) e `sort` (campo e direção, ex.: `dueDate,desc`).
- Retorno envelopado em objeto paginado padronizado contendo `content`, `pageable`, `totalElements`, `totalPages`, `last`, etc.

### 5.4. Padrão de Resposta de Erros
Todas as exceções tratadas pelo `GlobalExceptionHandler` retornam um corpo JSON padronizado:
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Dados da requisição inválidos",
  "details": ["legalName: Razão social é obrigatória"],
  "timestamp": "2026-11-09T14:00:00"
}
```

| HTTP Status | Código Semântico (`code`) | Cenário |
| :---: | :--- | :--- |
| **400** | `VALIDATION_ERROR` / `INVALID_FILE` | Falha de Bean Validation, arquivo vazio ou inválido |
| **401** | `UNAUTHORIZED` / `BAD_CREDENTIALS` | Token JWT ausente, expirado ou credenciais de login incorretas |
| **404** | `NOT_FOUND` | Recurso não localizado pelo identificador |
| **405** | — | Tentativa de utilizar método não suportado (ex.: `DELETE`) |
| **422** | `COMPANY_INACTIVE` / `USER_INACTIVE` / `INVALID_STATUS_TRANSITION` | Violação de regra de negócio (RN-006 inatividade ou RN-008 transição ilegal) |
| **500** | `STORAGE_ERROR` / `INTERNAL_SERVER_ERROR` | Falha interna de infraestrutura de disco ou erro inesperado |

### 5.5. Política de Cross-Origin Resource Sharing (CORS)
Para permitir que o frontend Flutter (executando via web browser em portas locais dinâmicas ou domínios de desenvolvimento) consuma a API REST com segurança:
- **Origens Permitidas:** Configuradas através da propriedade `cors.allowed-origin-patterns` (variável de ambiente `CORS_ALLOWED_ORIGIN_PATTERNS`), aceitando padrões com wildcard como `http://localhost:*` e `http://127.0.0.1:*`.
- **Métodos Permitidos:** `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `HEAD`.
- **Cabeçalhos Permitidos:** `*` (qualquer cabeçalho na requisição).
- **Cabeçalhos Expostos:** `Authorization`, `Content-Disposition`, `Location`.
- **Credenciais:** `allowCredentials: true` para suporte a autenticação e cookies.
- **Requisições Pre-flight (OPTIONS):** Permitidas globalmente (`/**`) com tempo de cache (`maxAge`) de 3600 segundos (1 hora).

---

## 6. Rastreabilidade com a SPEC-001

Este documento formaliza as decisões acordadas para a **SPEC-001** (Card Trello #1 - *Definir arquitetura, escopo do MVP e convenções*), servindo de base arquitetural compartilhada entre o backend e o frontend.

