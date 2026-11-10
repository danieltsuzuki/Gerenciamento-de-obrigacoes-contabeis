# Guia de Arquitetura e Padrões do Frontend (Flutter)

Este documento descreve a organização arquitetural, convenções de código e diretrizes visuais adotadas na aplicação Flutter do **Player Contabilidade**.

---

## 1. Organização Feature-First e Clean Architecture

A aplicação organiza o código sob o diretório `frontend/lib/` em duas estruturas principais: `core/` (infraestrutura e recursos compartilhados) e `features/` (módulos funcionais de negócio).

```text
frontend/lib/
├── core/
│   ├── config/              # AppConfig: ambiente dev/staging/prod e injeção de API_URL
│   ├── network/             # ApiClient, ApiException, PageResponse, DownloadedFile
│   ├── routing/             # AppRoutes: rotas nomeadas e factories de injeção
│   ├── theme/               # AppTheme: Material 3, cores corporativas e tipografia
│   ├── utils/               # Validadores e formatadores puros (ex.: CnpjValidator)
│   └── widgets/             # Componentes transversais reutilizáveis
│       ├── app_scaffold.dart       # Scaffold responsivo (Desktop Rail / Mobile Drawer + AppBar com Login)
│       ├── loading_state_view.dart # Spinner padronizado com mensagem
│       ├── error_state_view.dart   # Banner/alerta com botão de retry
│       └── empty_state_view.dart   # Ilustração de ausência de registros com botão de ação
│
└── features/
    ├── auth/                # Módulo de Autenticação e Sessão
    │   ├── data/            # AuthRemoteDataSource, AuthRepositoryImpl, AuthSessionStorage, DTOs
    │   ├── domain/          # AuthSession, AuthRepository
    │   └── presentation/    # LoginPage, RegisterPage, AuthSessionController, requireAuth (AuthGuard)
    ├── company/             # Módulo de Empresas Clientes
    │   ├── data/            # CompanyRemoteDataSource, CompanyRepositoryImpl, DTOs
    │   ├── domain/          # Company, CompanyRepository
    │   └── presentation/    # CompanyListPage, CompanyFormPage
    ├── responsible/         # Módulo de Responsáveis Contábeis
    │   ├── data/            # ResponsibleRemoteDataSource, ResponsibleRepositoryImpl, DTOs
    │   ├── domain/          # Responsible, ResponsibleRepository
    │   └── presentation/    # ResponsibleListPage, ResponsibleFormPage
    ├── obligation/          # Módulo de Obrigações Fiscais e Máquina de Estados
    │   ├── data/            # ObligationRemoteDataSource, ObligationRepositoryImpl, DTOs
    │   ├── domain/          # Obligation, ObligationStatus, ObligationRepository
    │   └── presentation/    # ObligationListPage, ObligationDetailPage, ObligationFormPage
    └── attachment/          # Módulo de Upload, Download e Gestão de Anexos
        ├── data/            # AttachmentRemoteDataSource, AttachmentRepositoryImpl
        ├── domain/          # Attachment, AttachmentRepository
        └── presentation/    # AttachmentListWidget, UploadAttachmentDialog
```

---

## 2. Responsabilidades das Camadas

### 2.1. Camada `domain`
- **Isolamento Total:** Não depende de Flutter UI (`package:flutter/material.dart`) nem de bibliotecas de transporte HTTP (`package:http`).
- **Entidades:** Classes imutáveis contendo propriedades de negócio e regras puras (ex.: `ObligationStatus.allowedTransitions`).
- **Contratos de Repositório:** Interfaces abstratas (`abstract class CompanyRepository`) que definem as operações permitidas no domínio.

### 2.2. Camada `data`
- **DataSources (`RemoteDataSource`):** Executam as requisições HTTP utilizando o `ApiClient`, serializam e desserializam JSON.
- **DTOs (Data Transfer Objects):** Modelos específicos de requisição (`CreateCompanyRequest`, `LoginRequest`) e resposta (`LoginResponse`).
- **Implementação do Repositório (`RepositoryImpl`):** Conecta a camada de dados ao domínio, orquestrando DataSources e convertendo DTOs em Entidades de domínio.
- **Armazenamento de Sessão (`AuthSessionStorage`):** Contrato e implementações para gravação e recuperação de tokens e dados da sessão.

### 2.3. Camada `presentation`
- **Isolamento de Transporte:** **NUNCA** realiza chamadas HTTP diretamente ou referencia URLs.
- **Consumo:** Consome exclusivamente o `Repository` injetado ou controladores de estado (`AuthSessionController`).
- **Páginas e Componentes:** Widgets modulares com chaves semânticas (`Key('...')`) para facilitar testes de interface automatizados.
- **Controle de Formulários:** Utiliza `GlobalKey<FormState>`, controladores de texto (`TextEditingController`) e validações síncronas inline.

---

## 3. Design System e Componentes Compartilhados

### 3.1. Paleta de Cores Institucional (`AppTheme`)
- **Azul Primário Corporativo:** `#1E3A8A` (utilizado em AppBars, botões primários e cabeçalhos).
- **Verde-azulado Secundário:** `#0D9488` (destaques secundários e tags informativas).
- **Sucesso:** `#16A34A` (badge de status `Concluída` e ativações).
- **Aviso:** `#D97706` (badge de status `Pendente`).
- **Informação / Andamento:** `#2563EB` (badge de status `Em andamento`).
- **Erro:** `#DC2626` (falhas de validação, erros de API e ações de logout).
- **Fundo Claro:** `#F8FAFC` com cards brancos `#FFFFFF` e bordas `#E2E8F0`.

### 3.2. Layout Adaptativo (`AppScaffold`)
- **Telas Largas (Web / Desktop >= 768px):** Exibe `NavigationRail` vertical fixo à esquerda com destinos principais (Obrigações, Empresas, Responsáveis).
- **Telas Compactas (Mobile < 768px):** Exibe `AppBar` com `Drawer` lateral e `NavigationBar` inferior.
- **Canto Superior Direito:** Exibe botão proeminente de **Login** quando anônimo (`auth-login-button`) e menu com dados e logout (`auth-user-menu`) quando autenticado.

### 3.3. Estados de Feedback Obrigatórios
Qualquer tela com carregamento assíncrono deve suportar:
1. `LoadingStateView`: Indicador centralizado com mensagem descritiva.
2. `ErrorStateView`: Mensagem de erro amigável acompanhada de botão de tentar novamente (`onRetry`).
3. `EmptyStateView`: Ícone semântico, mensagem de ausência de registros e botão de ação primária (ex.: "Nova Empresa", "Cadastrar Obrigação").

