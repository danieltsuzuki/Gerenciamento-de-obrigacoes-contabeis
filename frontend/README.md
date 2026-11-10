# Frontend — Gerenciador de Obrigações Contábeis

Aplicação cliente desenvolvida em **Flutter 3.29+ / Dart 3.7+** para o sistema **Player Contabilidade**, voltada ao gerenciamento de empresas clientes, responsáveis contábeis, obrigações fiscais e controle de prazos e comprovantes.

---

## 1. Arquitetura e Estrutura de Pastas

O projeto adota uma arquitetura **Feature-First** combinada com os princípios de **Clean Architecture**, isolando responsabilidades em camadas estritas e desacoplando completamente a interface dos detalhes de transporte HTTP:

```text
frontend/
├── lib/
│   ├── core/                       # Infraestrutura transversal e design system
│   │   ├── config/                 # AppConfig (gestão de ambiente dev/staging/prod e Base URL)
│   │   ├── network/                # ApiClient (HTTP, multipart, download), ApiException, PageResponse, DownloadedFile
│   │   ├── routing/                # AppRoutes (rotas nomeadas e injeção de dependências)
│   │   ├── theme/                  # AppTheme (paleta Material 3 e estilização institucional)
│   │   └── widgets/                # Widgets compartilhados (AppScaffold, Loading, Error, Empty)
│   ├── features/                   # Módulos funcionais independentes
│   │   ├── auth/                   # Autenticação e Registro
│   │   │   ├── data/               # AuthRemoteDataSource, AuthRepositoryImpl, AuthSessionStorage, DTOs (Login/Register)
│   │   │   ├── domain/             # AuthSession (entidade), AuthRepository (contrato)
│   │   │   └── presentation/       # LoginPage, RegisterPage, AuthSessionController, requireAuth (AuthGuard)
│   │   ├── company/                # Domínio de Empresas Clientes
│   │   │   ├── data/               # CompanyRemoteDataSource, CompanyRepositoryImpl, DTOs (Create/Update)
│   │   │   ├── domain/             # Company (entidade), CompanyRepository (contrato)
│   │   │   └── presentation/       # CompanyListPage, CompanyFormPage (cadastro e edição com validação de CNPJ)
│   │   ├── responsible/            # Domínio de Responsáveis Contábeis
│   │   │   ├── data/               # ResponsibleRemoteDataSource, ResponsibleRepositoryImpl, DTOs (Create/Update)
│   │   │   ├── domain/             # Responsible (entidade), ResponsibleRepository (contrato)
│   │   │   └── presentation/       # ResponsibleListPage
│   │   ├── obligation/             # Domínio de Obrigações Fiscais
│   │   │   ├── data/               # ObligationRemoteDataSource, ObligationRepositoryImpl, DTOs (Create/Update/Status)
│   │   │   ├── domain/             # Obligation (entidade com máquina de estados), ObligationRepository
│   │   │   └── presentation/       # ObligationListPage (filtros e chips por status)
│   │   └── attachment/             # Upload, Listagem e Download de Anexos
│   │       ├── data/               # AttachmentRemoteDataSource, AttachmentRepositoryImpl
│   │       └── domain/             # Attachment (entidade com formatação de tamanho), AttachmentRepository
│   └── main.dart                   # Inicialização da aplicação e bootstrap do AppConfig
├── test/                           # Suíte de testes unitários, mocks e de widgets (107 testes aprovados)
│   ├── core/
│   │   ├── config/                 # Testes de inicialização e customização de AppConfig
│   │   ├── network/                # Testes de ApiClient, Download, Multipart, PageResponse e ApiException
│   │   ├── utils/                  # Testes do CnpjValidator
│   │   └── widgets/                # Testes de AppScaffold (botão de login), Loading, Error e EmptyStateView
│   └── features/                   # Testes de integração de rede, telas e navegação
│       ├── auth/                   # Testes de AuthSessionStorage, AuthSessionController, LoginPage, RegisterPage e AuthGuard
│       ├── company/                # Testes de listagem, filtros, formulário de criação/edição e validação de CNPJ
│       ├── responsible/            # Testes de listagem, filtros, formulário de criação/edição, tela de detalhes e integração
│       ├── obligation/             # Testes de integração (DataSource/Repo) e de widgets (ObligationListPageTest)
│       ├── attachment/             # Testes de upload multipart, listagem e download de fluxo binário
│       └── navigation_test.dart    # Testes de fluxo e navegação entre páginas
├── pubspec.yaml                    # Dependências do projeto (http, http_parser, etc.)
└── analysis_options.yaml           # Regras do linter Dart/Flutter
```

---

## 2. Princípios de Implementação

1. **Clean Architecture e Desacoplamento:**
   - **Data:** Responsável por chamadas de rede e serialização/desserialização JSON (`RemoteDataSource`) e implementação dos repositórios (`RepositoryImpl`).
   - **Domain:** Entidades puras e contratos abstratos de repositório (`Repository`). Não depende de pacotes de UI ou bibliotecas HTTP.
   - **Presentation:** Widgets de visualização, formulários e páginas. Nunca realiza chamadas HTTP diretamente; interage exclusivamente com a camada de domínio/repositório.

2. **Tratamento Estruturado de Erros (`ApiException`):**
   - Mapeia o contrato de erro da API do backend (`code`, `message`, `details`).
   - Identifica semanticamente erros de validação (`400 VALIDATION_ERROR`), autenticação (`401 UNAUTHORIZED`), regras de negócio (`422 BUSINESS_RULE_VIOLATION` / `INVALID_STATUS_TRANSITION`) e falhas de rede (`CONNECTION_ERROR`).

3. **Design System & Componentes Reutilizáveis:**
   - **Material 3:** Esquema de cores corporativo com Azul Primário (`#1E3A8A`) e Verde-azulado Secundário (`#0D9488`).
   - **Estados Visuais Padronizados:**
     - `LoadingStateView`: Indicador de progresso centralizado.
     - `ErrorStateView`: Mensagem de erro descritiva com ação de tentar novamente (*retry callback*).
     - `EmptyStateView`: Ilustração de ausência de registros com botão de ação rápida.
   - **Layout Adaptativo (`AppScaffold`):** Alterna automaticamente entre `NavigationRail` em telas amplas (Web e Desktop) e `Drawer` / `NavigationBar` em telas compactas (Mobile).

---

## 3. Como Executar

### Pré-requisitos
- **Flutter SDK 3.29.1+**
- **Dart SDK 3.7.0+**
- Backend Spring Boot em execução (padrão em `http://localhost:8080`)

### 1. Obter dependências
```bash
flutter pub get
```

### 2. Executar a aplicação
Por padrão, a aplicação conecta em `http://localhost:8080`. Para especificar a URL da API em tempo de compilação/execução, utilize o parâmetro `--dart-define=API_URL=...`:

```bash
# Execução na Web (Google Chrome)
flutter run -d chrome --dart-define=API_URL=http://localhost:8080

# Execução no Desktop Windows
flutter run -d windows --dart-define=API_URL=http://localhost:8080

# Execução em modo release (Web)
flutter build web --dart-define=API_URL=http://seu-servidor-api:8080
```

---

## 4. Testes e Análise de Código

```bash
# Executar toda a suíte de testes automatizados
flutter test

# Executar com relatório de cobertura
flutter test --coverage

# Executar o analisador estático (linter)
flutter analyze
```
