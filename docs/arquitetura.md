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

O frontend em Flutter foi projetado para seguir a organização **Feature-First** combinada com **Clean Architecture** (Data / Domain / Presentation), espelhando com fidelidade as especificações funcionais (SPECs 13 a 23).

```
lib/
├── core/                       # Infraestrutura e utilitários transversais
│   ├── error/                  # Falhas e exceções mapeadas da API
│   ├── network/                # Cliente HTTP (Dio/Http) com interceptor JWT e base URL dinâmica
│   ├── routing/                # Definição de rotas da aplicação
│   ├── theme/                  # Design System, cores, tipografia e componentes comuns
│   └── utils/                  # Formatadores de CNPJ, datas ISO e máscaras
├── features/                   # Módulos funcionais independentes
│   ├── auth/                   # Autenticação e Registro
│   │   ├── data/               # AuthRemoteDataSource, AuthRepositoryImpl, UserModel
│   │   ├── domain/             # UserEntity, LoginUseCase, RegisterUseCase
│   │   └── presentation/       # LoginPage, RegisterPage, AuthBloc / AuthNotifier
│   ├── company/                # Gestão de Empresas
│   │   ├── data/               # CompanyRemoteDataSource, CompanyRepositoryImpl, CompanyModel
│   │   ├── domain/             # CompanyEntity, GetCompaniesUseCase, SaveCompanyUseCase
│   │   └── presentation/       # CompanyListPage, CompanyFormPage, CompanyBloc
│   ├── responsible/            # Gestão de Responsáveis
│   │   ├── data/               # ResponsibleRemoteDataSource, ResponsibleRepositoryImpl
│   │   ├── domain/             # ResponsibleEntity, GetResponsiblesUseCase
│   │   └── presentation/       # ResponsibleListPage, ResponsibleFormPage
│   ├── obligation/             # Gestão de Obrigações Fiscais e Ciclo de Vida
│   │   ├── data/               # ObligationRemoteDataSource, ObligationRepositoryImpl
│   │   ├── domain/             # ObligationEntity, ChangeStatusUseCase, GetObligationsUseCase
│   │   └── presentation/       # ObligationListPage, ObligationDetailPage, ObligationFormPage
│   └── attachment/             # Upload, Listagem e Abertura de Anexos
│       ├── data/               # AttachmentRemoteDataSource, AttachmentRepositoryImpl
│       ├── domain/             # AttachmentEntity, UploadAttachmentUseCase, DownloadAttachmentUseCase
│       └── presentation/       # AttachmentListWidget, UploadAttachmentDialog
└── main.dart                   # Inicialização da aplicação e injeção de dependências
```

### 3.1. Diretrizes de Integração Frontend <-> Backend
- **Armazenamento de Token:** O token JWT retornado no login deve ser persistido em armazenamento seguro local (ex.: `flutter_secure_storage`).
- **Interceptor HTTP:** Todas as requisições para `/api/**` (exceto `/api/auth/**`) adicionam automaticamente o cabeçalho `Authorization: Bearer <token>`. Em caso de resposta `401 Unauthorized`, o cliente deve limpar a sessão e redirecionar para a tela de Login.
- **Tratamento de Erros:** O cliente deve interpretar o JSON de erro padronizado (`code`, `message`, `details`) e apresentar mensagens amigáveis ao usuário para erros 400 (validação), 422 (regras de negócio como empresa inativa ou transição inválida) e 404 (não encontrado).

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

---

## 6. Rastreabilidade com a SPEC-001

Este documento formaliza as decisões acordadas para a **SPEC-001** (Card Trello #1 - *Definir arquitetura, escopo do MVP e convenções*), servindo de base arquitetural compartilhada entre o backend e o frontend.

