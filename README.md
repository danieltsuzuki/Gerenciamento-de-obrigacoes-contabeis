# Player Contabilidade

Sistema corporativo completo para gerenciamento de obrigações contábeis e fiscais, empresas clientes, responsáveis e controle rigoroso de prazos e documentos comprobatórios.

---

## Links de Entrega

| Recurso | Link | Observações |
|---|---|---|
| **Repositório Backend** | [github.com/danieltsuzuki/Gerenciamento-de-obrigacoes-contabeis/tree/master/backend](https://github.com/danieltsuzuki/Gerenciamento-de-obrigacoes-contabeis/tree/master/backend) | Módulo Spring Boot 4.1.2 / Java 21 em arquitetura Monorepo |
| **Repositório Frontend** | [github.com/danieltsuzuki/Gerenciamento-de-obrigacoes-contabeis/tree/master/frontend](https://github.com/danieltsuzuki/Gerenciamento-de-obrigacoes-contabeis/tree/master/frontend) | Aplicação Flutter 3.29.1 (Web, Desktop e Mobile) |
| **Pull Request Principal** | [github.com/danieltsuzuki/Gerenciamento-de-obrigacoes-contabeis/pulls](https://github.com/danieltsuzuki/Gerenciamento-de-obrigacoes-contabeis/pulls) | PR integrada direcionada para a branch `master` |
| **Quadro Trello do Projeto** | [trello.com/b/gHqJ3F2G/gerenciador-de-obrigações-contábeis](https://trello.com/b/gHqJ3F2G/gerenciador-de-obriga%C3%A7%C3%B5es-cont%C3%A1beis) | Planejamento, rastreabilidade de cards e evolução das entregas |

> **Nota sobre Monorepo:** Por decisão arquitetural unificada, backend e frontend residem no mesmo repositório sob as pastas `/backend` e `/frontend`, permitindo contratos de API, documentação técnica (`/docs`) e especificações de agente (`/.agent`) compartilhados e versionados harmonicamente.

---

## Estrutura do Projeto

```text
├── backend/                                # Módulo Backend (Spring Boot 4.1.2 / Java 21)
│   ├── src/main/java/.../playercontabilidadeback/
│   │   ├── auth/                           # Autenticação JWT, DTOs e serviços de login/registro
│   │   ├── company/                        # Gestão de empresas, validação CNPJ e repositories
│   │   ├── responsible/                    # Gestão de responsáveis contábeis e BCrypt
│   │   ├── obligation/                     # Obrigações fiscais, máquina de estados e consultas
│   │   ├── attachment/                     # Upload multipart, storage local e download seguro
│   │   ├── actuator/                       # Healthcheck e métricas de infraestrutura
│   │   └── shared/                         # Exception Handler, segurança JWT, CORS e validadores
│   ├── src/main/resources/
│   │   ├── db/migration/                   # Migrações versionadas do MySQL gerenciadas pelo Flyway
│   │   ├── application.yml                 # Configuração base
│   │   ├── application-dev.yml             # Perfil de desenvolvimento
│   │   └── application-prod.yml            # Perfil de produção
│   ├── Dockerfile                          # Build multi-stage e runtime com Temurin 21 JRE
│   ├── .dockerignore                       # Exclusão de artefatos de compilação locais
│   └── pom.xml                             # Dependências Maven e plugins JaCoCo/Surefire
│
├── frontend/                               # Módulo Frontend (Flutter 3.29.1 / Dart 3.7.0)
│   ├── lib/
│   │   ├── core/                           # Configurações globais, tema M3, rotas e cliente HTTP
│   │   │   ├── config/                     # AppConfig e injeção de parâmetros (API_URL)
│   │   │   ├── network/                    # ApiClient com Bearer JWT e ApiException padronizada
│   │   │   ├── routing/                    # Roteamento centralizado por AppRoutes
│   │   │   ├── theme/                      # Paleta institucional e Design System Material 3
│   │   │   ├── utils/                      # CnpjValidator e formatadores de data/tamanho
│   │   │   └── widgets/                    # AppScaffold adaptativo e estados visuais (Loading/Error/Empty)
│   │   └── features/                       # Clean Architecture modular por funcionalidade
│   │       ├── auth/                       # Sessão, AuthGuard, telas de Login e Registro
│   │       ├── company/                    # Listagem paginada, detalhes e formulário de empresas
│   │       ├── responsible/                # Listagem paginada, detalhes e formulário de responsáveis
│   │       ├── obligation/                 # Listagem, detalhes, formulário e máquina de estados
│   │       └── attachment/                 # FilePicker e FileSaver nativos (Web / Desktop / IO)
│   ├── test/                               # 172 testes automatizados unitários e de widgets
│   ├── Dockerfile                          # Build Flutter Web multi-stage servido via Nginx Alpine
│   ├── nginx.conf                          # Configuração Nginx com suporte a SPA e gzip
│   ├── .dockerignore                       # Exclusão de artefatos e cache de build
│   └── pubspec.yaml                        # Dependências Flutter
│
├── docs/                                   # Documentação técnica viva e alinhada ao código
│   ├── api.md                              # Contratos completos de todos os 18 endpoints REST
│   ├── arquitetura.md                      # Decisões arquiteturais, fluxos e convenções de código
│   ├── modelo-de-dados.md                  # Diagrama ER, tabelas, chaves e constraints MySQL
│   ├── status-implementacao.md             # Matriz de regras de negócio e cobertura JaCoCo
│   ├── pendencias-e-perguntas-em-aberto.md # Decisões consolidadas e direcionamentos futuros
│   ├── decisoes/ADR-0001-...               # Registro formal de decisão arquitetural (ADR)
│   └── CHANGELOG.md                        # Histórico de mudanças no padrão Keep a Changelog
│
├── .agent/                                 # Especificações formais (SPECs 01 a 41) e diretrizes
├── docker-compose.yml                      # Orquestração de MySQL, Backend e Frontend via perfis
├── .env.example                            # Modelo de variáveis de ambiente do ecossistema
└── README.md                               # Guia central de execução e apresentação do sistema
```

---

## Tecnologias Utilizadas

### Backend
- **Linguagem:** Java 21 LTS
- **Framework:** Spring Boot 4.1.2 (WebMvc, Data JPA, Security, Validation, Actuator)
- **Segurança:** JJWT (`io.jsonwebtoken` 0.12.6) e `BCryptPasswordEncoder`
- **Banco de Dados:** MySQL 8.0 com migrações gerenciadas pelo Flyway 10
- **Documentação de API:** SpringDoc OpenAPI 2.8.5 (Swagger UI 3.0)
- **Métricas de Qualidade:** JaCoCo 0.8.12 (> 86% de cobertura de código geral, 100% nos controllers)
- **Testes Automatizados:** JUnit 5, Mockito 5, Spring Test e Testcontainers 2.0.5 (MySQL 8)

### Frontend
- **Framework:** Flutter 3.29.1
- **Linguagem:** Dart 3.7.0
- **Design System:** Material 3 com adaptação responsiva (Desktop, Web e Mobile)
- **Armazenamento Seguro:** `flutter_secure_storage` 10.3.4 (sessão e token JWT)
- **Comunicação HTTP:** Cliente `http` 1.3.0 desacoplado com tradução padronizada de exceções
- **Testes Automatizados:** `flutter_test` (172 testes unitários, mocks e widget tests aprovados com zero exceções não tratadas)

### Infraestrutura e DevOps
- **Contêineres:** Docker com builds multi-stage otimizados
- **Orquestração:** Docker Compose com perfis de infraestrutura (`infra`) e stack completa (`full`)
- **Servidor Web Estático:** Nginx Alpine para distribuição otimizada do Flutter Web

---

## Funcionalidades Implementadas

### Backend (API REST)
- **Autenticação e Segurança (JWT):** Autenticação stateless via `POST /api/auth/login` e autocadastro público em `POST /api/auth/register`, emitindo tokens Bearer JWT com senhas protegidas via `BCrypt`.
- **API de Empresas (`/api/companies`):** Cadastro com validação estrita de dígitos verificadores de CNPJ e unicidade, listagem paginada com filtro por situação (`active`), busca por identificador e inativação lógica (*soft delete*).
- **API de Responsáveis (`/api/responsibles`):** Gestão de responsáveis contábeis com e-mail único, listagem paginada com filtros e inativação lógica. Senhas nunca são expostas em DTOs.
- **API de Obrigações Fiscais (`/api/obligations`):** Cadastro de obrigações fiscais vinculando obrigatoriamente empresa e responsável ativos (RN-006). Toda obrigação nasce no status inicial `PENDING`. Listagem com filtros combináveis (`companyId`, `responsibleId`, `status`, intervalo de `dueDate` via `dueFrom` e `dueTo`) e busca detalhada.
- **Máquina de Estados de Obrigações (RN-008):** Transição controlada via `PATCH /api/obligations/{id}/status`:
  - `PENDING -> IN_PROGRESS`
  - `IN_PROGRESS -> COMPLETED` (preenchimento automático de `completed_at`)
  - Bloqueio estrito de saltos, regressões e reabertura a partir de `COMPLETED` (estado terminal).
- **API de Anexos (`/api/obligations/{id}/attachments` e `/api/attachments/{id}/download`):** Upload multipart (`multipart/form-data`) de comprovantes fiscais com validação de arquivo, armazenamento local seguro (`storage.location`) com proteção contra *Path Traversal*, metadados persistidos no MySQL e mecanismo de compensação em caso de erro no banco.
- **Sem Exclusão Física (ADR-0001):** Repositórios e controladores não expõem métodos `delete*`; tentativas de `DELETE` HTTP retornam `405 Method Not Allowed`, preservando o histórico fiscal.
- **Documentação Interativa (OpenAPI 3 / Swagger UI):** Interface gráfica com suporte completo a autenticação Bearer JWT via botão **Authorize**.
- **Cobertura de Testes (JaCoCo):** Mais de 86% de cobertura de linhas geral, 100% nos controllers e 171 testes automatizados (unitários e de integração com Testcontainers).

### Frontend (Flutter)
- **Estrutura Modular por Features:** Arquitetura limpa organizada em camadas (`data`, `domain`, `presentation`) para `company`, `responsible`, `obligation`, `attachment` e `auth`.
- **Navegação e Layout Adaptativo:** `AppScaffold` com alternância automática entre `NavigationRail` (telas largas / Desktop / Web) e `Drawer` / `NavigationBar` (telas menores / Mobile).
- **Autenticação e Sessão Persistida:** Tela de login e cadastro integrado, `AuthGuard` protegendo ações restritas, botão de login/perfil no topo direito e redirecionamento suave em expiração de token.
- **Listagem e Gestão de Obrigações:** Visualização de título, empresa, responsável, status com chips coloridos institucionais, quantidade de anexos e data de criação formatada. Chips de filtro rápido por status (`Pendente`, `Em andamento`, `Concluída`).
- **Formulário de Obrigações:** Cadastro e edição com seleção intuitiva de empresa e responsável ativos via dropdown, seletor de data (`DatePicker`) com validações síncronas.
- **Detalhes da Obrigação e Ciclo de Vida:** Visualização completa dos dados da obrigação, botões para avanço de status segundo as regras de negócio e máquina de estados.
- **Gestão de Anexos:** Seleção direta de documentos do computador através do botão "Anexar Arquivo" (sem modais desnecessários) com suporte nativo multiplataforma (Web e Desktop) e download seguro diretamente pelo card.
- **Gestão de Empresas e Responsáveis:** Listagem paginada com chips de filtro por situação cadastral (Todas / Ativas / Inativas), formulários com validação inline de CNPJ e e-mail e telas de detalhes com histórico.
- **Resiliência e Tratamento de Erros:** Componentes reutilizáveis `LoadingStateView`, `ErrorStateView` (com botão de retry) e `EmptyStateView`. Zero exceções não tratadas em falhas de rede ou validação.

---

## Decisões Arquiteturais

1. **Abordagem Monorepo:** Centralização dos códigos de backend e frontend no mesmo repositório com pastas independentes (`/backend` e `/frontend`), compartilhando a documentação viva em `/docs` e os arquivos de configuração de ambiente (`.env.example`).
2. **Package by Feature (Backend):** Organização do código Spring Boot pelo domínio de negócio (`auth`, `company`, `responsible`, `obligation`, `attachment`, `shared`) em vez de camadas técnicas puras, garantindo alta coesão e baixo acoplamento.
3. **Clean Architecture Feature-First (Frontend):** Separação estrita em camadas (`data`, `domain`, `presentation`) para cada funcionalidade, isolando regras de negócio e modelos da renderização de widgets da UI.
4. **Sem Exclusão Física (Soft Delete — ADR-0001):** Proibição arquitetural de operações `DELETE`. Empresas e responsáveis são inativados via flag `active: false`. As chaves estrangeiras no banco de dados não utilizam `ON DELETE CASCADE`, impedindo exclusão acidental de obrigações históricas.
5. **Máquina de Estados Finita e Imutabilidade Terminal:** Toda obrigação nasce obrigatoriamente no status `PENDING`. As transições são lineares (`PENDING -> IN_PROGRESS -> COMPLETED`). O status `COMPLETED` é terminal (não admite reabertura nem regressão), e o campo `completed_at` é preenchido pelo servidor no momento da conclusão.
6. **Autenticação Stateless com JWT:** Utilização de tokens Bearer JWT assinados com HMAC-SHA256 (mínimo de 32 bytes) com senhas criptografadas via `BCrypt`. Endpoints de leitura (`GET`) são abertos para consulta pública, enquanto operações de mutação (`POST`, `PUT`, `PATCH`) e de anexos exigem token válido.
7. **Armazenamento Físico de Arquivos em Filesystem Seguro:** Arquivos físicos são gravados fora do banco de dados no diretório local configurável, utilizando caminhos gerados pelo servidor (`{obligationId}/{uuid}.{ext}`) para proteção absoluta contra *Path Traversal*. Os metadados são registrados no MySQL com mecanismo de compensação em caso de falha de persistência.
8. **Migrations Versionadas com Flyway:** Todo o esquema relacional do banco de dados é inicializado e mantido exclusivamente através de migrações SQL versionadas (`V1__create_schema.sql`, `V2__...`), garantindo paridade de ambientes entre desenvolvimento, testes (Testcontainers) e produção.
9. **Gerenciamento de Estado Nativo no Flutter:** Em conformidade com as diretrizes do projeto, não foram introduzidas bibliotecas de terceiros externas de gerência de estado (como Bloc, MobX ou GetX). O frontend utiliza os recursos padrão e declarativos do Flutter (`ChangeNotifier`, `ValueNotifier` e `StatefulWidget`), garantindo código limpo, sustentável e sem complexidade acidental.

Consulte os registros formais de decisão em [`docs/decisoes/`](docs/decisoes/).

---

## Como Rodar o Projeto

### Pré-requisitos
- **JDK 21** instalado e configurado no PATH
- **Flutter SDK 3.29+** e **Dart 3.7+**
- **Docker** e **Docker Compose**
- **Git**

---

### Opção 1: Execução Completa com Docker Compose (Recomendada)

Para subir toda a stack (Banco de Dados MySQL, API Spring Boot e Frontend Flutter Web) com um único comando:

1. Configure o arquivo de ambiente:
   ```bash
   cp .env.example .env
   ```

2. Execute o compose com o perfil `full`:
   ```bash
   docker compose --profile full up -d --build
   ```

3. Acesse os serviços no seu navegador:
   - **Frontend Flutter Web:** [http://localhost:8081](http://localhost:8081)
   - **Backend API REST:** [http://localhost:8080](http://localhost:8080)
   - **Swagger UI:** [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
   - **Healthcheck da API:** [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)

4. Para encerrar a execução:
   ```bash
   docker compose --profile full down
   ```

---

### Opção 2: Execução Local em Modo Desenvolvimento

#### 1. Configurar Variáveis de Ambiente
Na raiz do projeto:
```bash
cp .env.example .env
```

| Variável | Descrição | Valor Padrão / Exemplo |
|---|---|---|
| `DB_PORT` | Porta exposta pelo MySQL | `3306` |
| `DB_NAME` | Nome do banco de dados | `player_contabilidade` |
| `DB_USERNAME` | Usuário da aplicação no MySQL | `player_user` |
| `DB_PASSWORD` | Senha do usuário da aplicação | `player_secret_password` |
| `DB_ROOT_PASSWORD` | Senha de root do MySQL | `player_root_password` |
| `DB_URL` | JDBC URL de conexão | `jdbc:mysql://localhost:3306/player_contabilidade?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true` |
| `JWT_SECRET` | Chave secreta HMAC-SHA (mín. 32 bytes) | `sua-chave-secreta-jwt-muito-longa-e-segura-32-bytes` |
| `JWT_EXPIRATION_MS`| Tempo de validade do token (ms) | `1800000` (30 minutos) |
| `STORAGE_LOCATION` | Diretório no disco para anexos | `uploads` |
| `CORS_ALLOWED_ORIGIN_PATTERNS` | Padrões de origens CORS permitidas | `http://localhost:*,http://127.0.0.1:*` |
| `BACKEND_PORT` | Porta HTTP do container backend | `8080` |
| `FRONTEND_PORT` | Porta HTTP do container frontend | `8081` |
| `API_URL` | URL base consumida pelo frontend | `http://localhost:8080` |

#### 2. Iniciar o Banco de Dados MySQL
Suba apenas o serviço do MySQL utilizando o compose:
```bash
docker compose up -d
```

#### 3. Executar o Backend
A partir do diretório `backend/`:
```bash
# Windows
.\mvnw.cmd spring-boot:run

# Linux / macOS
./mvnw spring-boot:run
```

#### 4. Executar os Testes do Backend
A partir do diretório `backend/`:
```bash
# Windows
.\mvnw.cmd test

# Linux / macOS
./mvnw test

# Executar testes com validação obrigatória de thresholds mínimos de cobertura (SPEC-040)
# Falha a compilação se BUNDLE < 85%, Controllers < 90% ou Services < 90%
.\mvnw.cmd verify
```
*O relatório detalhado de cobertura JaCoCo estará disponível em `backend/target/site/jacoco/index.html`.*

#### 5. Executar o Frontend (Flutter)
A partir do diretório `frontend/`:
```bash
# Obter dependências
flutter pub get

# Executar na Web (Chrome) apontando para a API local
flutter run -d chrome --dart-define=API_URL=http://localhost:8080

# Ou executar na plataforma Desktop (Windows)
flutter run -d windows --dart-define=API_URL=http://localhost:8080
```

#### 6. Executar os Testes e Análise Estática do Frontend
A partir do diretório `frontend/`:
```bash
# Executar suíte de testes unitários e de widgets (199 testes)
flutter test

# Executar com geração do relatório de cobertura lcov
flutter test --coverage

# Validar limite mínimo de cobertura do frontend (SPEC-040, meta: >= 80.00%)
python tool/check_coverage.py

# Executar análise estática de código
flutter analyze
```

---

## Documentação Interativa com Swagger UI

Após iniciar o backend, acesse no navegador:
- **Swagger UI:** [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON:** [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)

### Como autenticar no Swagger UI:
1. Realize o login no endpoint `POST /api/auth/login` (ou crie um usuário em `POST /api/auth/register`).
2. Copie o valor do campo `token` retornado no JSON.
3. Clique no botão **Authorize** (cadeado verde no canto superior direito).
4. No campo **bearerAuth**, informe o token JWT e confirme.

---

## Melhorias Futuras

O roadmap de evolução contínua da aplicação está mapeado e documentado nas especificações detalhadas:

1. **Paginação Avançada no Frontend (SPEC-032):** Suporte a rolagem infinita e controles de página nas listagens de obrigações, empresas e responsáveis.
2. **Pesquisa Textual Unificada (SPEC-033):** Campo de busca global (`SearchBar`) com debounce na API e no Flutter por razão social, CNPJ, responsável e título.
3. **Filtros Avançados (SPEC-034):** Painel de filtros combinados por período de vencimento (`dueFrom`/`dueTo`), empresa e atalho rápido para "Obrigações Atrasadas".
4. **Auditoria e Trilha de Histórico (SPEC-035):** Implementação de Spring Data JPA Auditing (`created_by`/`updated_by`) e tabela dedicada de histórico de transições de status com linha do tempo visual no Flutter.
5. **Logs Estruturados e Rastreabilidade (SPEC-036):** Configuração de logs em formato JSON com propagação de Correlation ID (`X-Request-Id`) via MDC para observabilidade completa.
6. **Cache de Alta Performance (SPEC-037):** Cache em memória com Caffeine para entidades de referência e dados com baixa volatilidade (empresas e responsáveis ativos).
7. **Tema Claro e Escuro (SPEC-038):** Alternador de tema visual no Flutter (`ThemeMode.light`, `ThemeMode.dark`, `ThemeMode.system`) com persistência de preferências do usuário.
8. **Pipeline Automatizado de CI/CD (SPEC-039):** Workflows do GitHub Actions para validação contínua de testes, análise estática, build e publicação de contêineres no GHCR.
9. **Metas Rígidas de Cobertura de Testes (SPEC-040):** Enforce de cobertura mínima no build (`jacoco:check` ≥ 85% e cobertura de código no Flutter).
10. **Refinamentos de Negócio Consolidados (SPEC-041):**
    - Imutabilidade absoluta (100%) de anexos em obrigações com status `COMPLETED`.
    - Bloqueio de autorização exigindo que apenas o responsável atribuído à obrigação avance o status (`403 Forbidden`).
    - Destaque visual destacado no frontend para obrigações com prazo vencido (`isOverdue`).
    - Suporte pleno ao novo padrão de CNPJ alfanumérico da Receita Federal.

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
