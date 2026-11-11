# SPEC-038 — Implementar tema claro e escuro, centralização de modais, selects pesquisáveis, filtros/ordenação e controle de acesso visual com mensagens amigáveis no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 2.2 |
| Situação da especificação | Aprovada |
| Tipo | Diferencial (não obrigatório) — **Design System, Temas, Usabilidade e Acessibilidade** |

## 1. Objetivo

Alinhar a aplicação Flutter à identidade visual corporativa da Player Contabilidade, fornecendo temas claro e escuro com suporte a alternância em tempo de execução, padronizar a centralização vertical e horizontal de todos os modais/diálogos na tela, assegurar que todos os campos de seleção (selects) sejam interativos e pesquisáveis, estender os recursos de filtros avançados e ordenação dinâmica para as páginas de Empresas e Responsáveis, e implementar um controle rigoroso de visibilidade de ações para usuários anônimos (escondendo botões de adição e remoção em toda a aplicação), com mensagens de orientação acolhedoras, empáticas e amigáveis quando o usuário precisar estar logado ou não possuir permissão para realizar determinada ação.

## 2. Situação atual

- **Temas:** `AppTheme` define apenas tema claro baseado em tons de azul genéricos; não há suporte a `darkTheme`, `ThemeMode` ou persistência local da preferência de tema.
- **Modais e Diálogos:** Alguns diálogos e BottomSheets aparecem desbalanceados verticalmente ou ancorados na base da tela, requerendo alinhamento estritamente centralizado (`Alignment.center`) na viewport.
- **Campos de Seleção:** O formulário de obrigações implementou `SearchableSelectFormField` para empresa e responsável, mas outros seletores e filtros na aplicação ainda usam dropdowns convencionais ou precisam de padronização pesquisável e centralizada.
- **Filtros e Ordenação:** A listagem de obrigações (`ObligationListPage`) possui modal de filtros avançados, chips de filtros ativos e menu de ordenação configurável, enquanto as listagens de Empresas (`CompanyListPage`) e Responsáveis (`ResponsibleListPage`) possuem apenas busca textual e chips simples de situação cadastral, sem ordenação selecionável nem modal de filtros avançados completo com badges de filtros ativos.
- **Controle Visual e Mensagens de Acesso:** Botões de edição já foram ocultados para usuários anônimos, mas botões de **adição** (FABs `+` de nova empresa, novo responsável e nova obrigação, botão de anexar arquivo) ou botões de **remoção/inativação** ainda são renderizados para usuários não logados. Além disso, as mensagens de exigência de autenticação ou falta de permissão por vezes utilizam linguagem técnica ou impessoal ("Unauthorized", "401", "Acesso restrito").

## 3. Identidade Visual e Paleta de Cores

A aplicação deve adotar rigorosamente as cores da marca em ambos os temas:

| Cor | Hex | Nome | Uso Principal |
|---|---|---|---|
| **Primary Navy** | `#17152F` | Cor institucional principal | AppBars, NavigationRail/Drawer, headers principais, botões primários no tema claro; cor de fundo base e superfícies profundas no tema escuro. |
| **Brand Yellow** | `#F5A900` | Cor de destaque | Acentos principais, indicadores de seleção, botões de ação chave (CTAs), barras de progresso e elementos focais. |
| **Accent Yellow** | `#FFC52E` | Destaques e interações | Estados de hover/focus, badges de alerta/atenção, detalhes interativos e realce de textos em superfícies escuras. |
| **White** | `#FFFFFF` | Superfícies claras | Superfícies de cards e fundos no tema claro; tipografia e ícones de alto contraste sobre fundos escuros/navy. |

### 3.1. Diretrizes para o Tema Claro
- **Background geral:** Neutro claro (`#F8FAFC` ou `#FFFFFF`).
- **Cards e Diálogos:** Superfície `#FFFFFF` com bordas sutis (`#E2E8F0`).
- **Texto principal:** `#17152F` (Primary Navy) para títulos e `#334155` para corpo, garantindo conformidade com contraste WCAG AA.
- **Ações e Realces:** Botões primários em `#17152F` com texto `#FFFFFF` ou botões de destaque em `#F5A900` com texto `#17152F`.

### 3.2. Diretrizes para o Tema Escuro
- **Background geral:** `#100E22` a `#17152F` (Navy profundo).
- **Cards e Diálogos:** `#1F1C3D` a `#26234B` com bordas em `#36335F`.
- **Texto principal:** `#FFFFFF` para títulos e `#CBD5E1` para corpo.
- **Ações e Realces:** Destaques e ícones ativos em `#FFC52E` / `#F5A900`, fornecendo leitura nítida e confortável sem saturação excessiva.

## 4. Escopo Funcional

### 4.1. Tema Claro e Escuro
- [ ] Implementar `AppTheme.light` e `AppTheme.dark` orientados por `ColorScheme` utilizando a paleta oficial (`#17152F`, `#F5A900`, `#FFC52E`, `#FFFFFF`).
- [ ] Controlador de tema (`ThemeController`) gerenciando `ThemeMode` (Sistema / Claro / Escuro).
- [ ] Persistência da preferência do usuário localmente (via storage existente ou chave em memória/local storage).
- [ ] Alternador de tema acessível no `AppScaffold` (canto superior da AppBar ou rodapé do menu de navegação) com ícone dinâmico (`light_mode` / `dark_mode`) e tooltip explicativo.
- [ ] Garantir que badges de status de obrigações (`PENDING`, `IN_PROGRESS`, `COMPLETED`), avatares e indicadores mantenham legibilidade e contraste adequado nos dois temas.

### 4.2. Centralização de Modais e Diálogos
- [ ] Todos os diálogos da aplicação (`AlertDialog`, `Dialog`, modais de autenticação, diálogos de confirmação de status, modals de seleção e filtros) devem ser exibidos centralizados na tela (`alignment: Alignment.center`).
- [ ] Evitar modais deslocados para a base da tela ou que exijam rolagem desnecessária quando a viewport tiver espaço suficiente.
- [ ] Definir restrições responsivas adequadas (`maxWidth: 520` a `600px`, `maxHeight` dinâmico com rolagem interna) para visualização consistente em web desktop, tablet e mobile.

### 4.3. Campos de Seleção (Selects) Pesquisáveis
- [ ] Padronizar todos os campos de seleção da aplicação com o componente pesquisável `SearchableSelectFormField` (ou componente modal centralizado correspondente):
  - Seleção de Empresa Cliente em formulários e filtros.
  - Seleção de Responsável Atribuído em formulários e filtros.
  - Seleção de Status e outros filtros com opções múltiplas.
- [ ] Cada componente select deve fornecer:
  - Campo de entrada com layout padronizado integrado ao tema.
  - Ao clicar, abertura de modal **centralizado na tela**.
  - Campo de pesquisa em tempo real com auto-foco e botão de limpar busca.
  - Lista filtrada com indicação clara do item selecionado e suporte a teclado.
  - Estado vazio estilizado quando nenhum item corresponder ao termo pesquisado.

### 4.4. Filtros Avançados e Ordenação em Empresas e Responsáveis
- [ ] **Empresas (`CompanyListPage`):**
  - Modal de filtros avançados centralizado na tela (`Dialog` com `maxWidth: 520px` e cantos arredondados).
  - Filtro por situação cadastral (`Todas`, `Ativas`, `Inativas`).
  - Menu/seletor de ordenação configurável (`sort`):
    - Razão Social (A-Z) (`legalName,asc`)
    - Razão Social (Z-A) (`legalName,desc`)
    - CNPJ (`cnpj,asc`)
    - Mais recentes primeiro (`id,desc`)
    - Mais antigas primeiro (`id,asc`)
  - Contador de filtros ativos no botão de filtro (ex.: `Filtros (1)`).
  - Barra de chips de filtros ativos com remoção individual e botão "Limpar todos".
- [ ] **Responsáveis (`ResponsibleListPage`):**
  - Modal de filtros avançados centralizado na tela (`Dialog` com `maxWidth: 520px` e cantos arredondados).
  - Filtro por situação cadastral (`Todos`, `Ativos`, `Inativos`).
  - Menu/seletor de ordenação configurável (`sort`):
    - Nome (A-Z) (`name,asc`)
    - Nome (Z-A) (`name,desc`)
    - E-mail (`email,asc`)
    - Mais recentes primeiro (`id,desc`)
    - Mais antigos primeiro (`id,asc`)
  - Contador de filtros ativos no botão de filtro (ex.: `Filtros (1)`).
  - Barra de chips de filtros ativos com remoção individual e botão "Limpar todos".
- [ ] Integração com paginação e busca textual `q`: qualquer alteração em filtros ou ordenação reseta automaticamente a página atual para `0`.

### 4.5. Ocultação de Botões de Mutação para Anônimos e Mensagens Amigáveis
- [ ] **Ocultação de Botões de Adição e Remoção para Usuários Deslogados (`!isAuthenticated`):**
  - Em `CompanyListPage`, ocultar completamente o botão flutuante (`FloatingActionButton`) de cadastrar nova empresa quando não autenticado.
  - Em `ResponsibleListPage`, ocultar completamente o botão flutuante (`FloatingActionButton`) de cadastrar novo responsável quando não autenticado.
  - Em `ObligationListPage`, ocultar completamente o botão flutuante (`FloatingActionButton`) de cadastrar nova obrigação quando não autenticado.
  - Em `ObligationDetailPage`, ocultar o botão de "Anexar Arquivo" quando não autenticado.
  - Em todas as telas de formulário e detalhe, ocultar botões de inativação, exclusão ou remoção de entidades/anexos quando o usuário não estiver autenticado.
- [ ] **Mensagens Amigáveis, Claras e Orientativas:**
  - Substituir mensagens técnicas de erro ou bloqueio (como "401", "Unauthorized", "Acesso restrito", "Sessão inválida") por textos acolhedores e empáticos em português claro, explicando o motivo da exigência e facilitando a ação do usuário:
    - **Tentativa de criação/adição:** *"Para cadastrar novas empresas, responsáveis ou obrigações fiscais, faça login com sua conta corporativa."*
    - **Tentativa de manipulação de anexos:** *"Para enviar, consultar ou baixar documentos fiscais com segurança, acesse sua conta."*
    - **Tentativa de alteração de status:** *"Para registrar o andamento ou conclusão desta obrigação, acesse sua conta."*
    - **Sessão expirada ou sem permissão:** *"Sua sessão expirou por segurança. Conecte-se novamente para continuar gerenciando suas obrigações sem perder seus dados."*
  - Diálogos de autenticação necessária com design limpo, ícone ilustrativo (`Icons.lock_outline` ou similar), botão destacado em Brand Yellow (`#F5A900`) com texto "Fazer Login" e opção de fechar para continuar navegando como leitor.

## 5. Regras e Restrições

- Cores devem ser consumidas exclusivamente via `Theme.of(context).colorScheme` ou constantes do `AppTheme` baseadas na paleta da marca, sem valores hexadecimais aleatórios dispersos nos widgets.
- A alternância de tema deve ser puramente local (client-side), sem dependência de requisições de backend.
- A abertura de qualquer modal ou select pesquisável não deve bloquear o loop de eventos nem causar estouro de layout (*overflow*).
- Parâmetros de ordenação e filtros devem consumir exatamente os parâmetros já expostos pela API Spring Data (`sort`, `active`, `q`, `page`, `size`).
- O usuário anônimo deve ter acesso transparente e irrestrito à consulta e navegação, mas não deve visualizar botões de ação que não tenha permissão de executar.
- Manter total conformidade com `flutter analyze` sem alertas ou dead code.

## 6. Critérios de Aceitação

- [ ] A aplicação inicializa no tema configurado (ou segue o sistema por padrão) e reflete a nova paleta da marca.
- [ ] Ao alternar entre tema claro e escuro, toda a interface (AppScaffold, cards, tabelas, textos, inputs e botões) atualiza imediatamente.
- [ ] A preferência de tema é persistida entre recarregamentos da página.
- [ ] Todos os modais da aplicação abrem estritamente centralizados na tela.
- [ ] Todos os seletores/selects da aplicação contam com modal centralizado e campo de busca funcional.
- [ ] `CompanyListPage` possui modal de filtros avançados centralizado, seletor de ordenação e barra de chips de filtros ativos funcionais.
- [ ] `ResponsibleListPage` possui modal de filtros avançados centralizado, seletor de ordenação e barra de chips de filtros ativos funcionais.
- [ ] Botões de **adição** (FABs de Empresas, Responsáveis, Obrigações e botão de Anexar) e de **remoção/inativação** ficam 100% invisíveis para usuários deslogados.
- [ ] Diálogos e mensagens de permissão e autenticação exibem textos acolhedores, amigáveis e com ação direta para login.
- [ ] Suíte de testes do Flutter (`flutter test`) cobre a alternância de temas, modais centralizados, selects pesquisáveis, filtros/ordenação e a ocultação de botões de mutação para usuários anônimos.

## 7. Cenários de Teste

- **Tema Claro:** Renderizar páginas principais e verificar background claro, AppBar/Cards com Primary Navy `#17152F` e destaques em `#F5A900`.
- **Tema Escuro:** Alternar tema e validar background escuro `#17152F`, cards destacados e texto de alto contraste `#FFFFFF`/`#FFC52E`.
- **Modais Centralizados:** Abrir modais (confirmação, filtros, formulários) e validar que o widget `Dialog` / `AlertDialog` está centralizado na tela.
- **Selects Pesquisáveis:** Clicar em seletor, verificar modal centralizado, digitar filtro de pesquisa e validar filtragem correta da lista.
- **Filtros e Ordenação de Empresas e Responsáveis:** Abrir modais de filtros nas listagens, alternar ordenação e validar atualização correta dos dados e chips.
- **Usuário Deslogado (Ocultação de Ações):** Entrar como usuário anônimo e validar ausência de FABs nas 3 listagens, ausência do botão "Anexar Arquivo" e ausência de botões de edição/remoção.
- **Mensagens Amigáveis:** Simular sessão expirada ou acesso direto restrito e verificar exibição de mensagem humanizada e botão de login.
- **Regressão:** Verificar que as regras de negócio existentes (fluxo de status, login, filtros de obrigações, paginação) continuam íntegras e aprovadas.

## 8. Dependências

- SPEC-013, SPEC-015, SPEC-016, SPEC-017, SPEC-018, SPEC-019, SPEC-026, SPEC-032, SPEC-034.

## 9. Rastreabilidade

- `frontend/lib/core/theme/app_theme.dart`, `frontend/lib/core/widgets/searchable_select_form_field.dart`, `frontend/lib/features/company/presentation/pages/company_list_page.dart`, `frontend/lib/features/responsible/presentation/pages/responsible_list_page.dart`, `frontend/lib/features/obligation/presentation/pages/obligation_list_page.dart`, `frontend/README.md`.


