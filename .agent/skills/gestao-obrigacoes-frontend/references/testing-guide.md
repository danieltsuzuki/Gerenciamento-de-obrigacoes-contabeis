# Guia de Testes Automatizados no Frontend (Flutter)

Este documento estabelece as boas práticas, padrões e diretrizes para implementação e execução de testes automatizados na aplicação Flutter do **Player Contabilidade**.

---

## 1. Princípios e Estratégia de Testes

1. **Execução Headless sem Dependência de Canais Nativos:**
   - Testes automatizados executam via `flutter test` em linha de comando.
   - Para evitar que plugins com canais de plataforma C++/Kotlin/Swift (como `flutter_secure_storage`) falhem durante os testes headless, utilize a abstração `InMemoryAuthSessionStorage` ou instâncias mockadas.
2. **Isolamento de Rede:**
   - Testes unitários e testes de widgets **NUNCA** realizam chamadas HTTP reais a servidores externos.
   - Utilize mocks de `http.Client` (`MockClient` do pacote `http/testing.dart`) ou implementações falsas de repositório (`FakeCompanyRepository`, `FakeObligationRepository`).
3. **Chaves Semânticas (`Key`):**
   - Todos os elementos interativos fundamentais (inputs, botões de ação, chips de filtro, cards de item e banners de erro) devem possuir uma `Key` semântica para localização determinística nos testes:
     - `auth-login-button`, `auth-user-menu`
     - `login-email-input`, `login-password-input`, `login-submit-button`, `login-error-banner`
     - `register-name-input`, `register-email-input`, `register-password-input`, `register-confirm-password-input`
     - `company-card-{id}`, `company-edit-button-{id}`, `company-filter-{all,active,inactive}`
     - `obligation-card-{id}`, `obligation-status-chip`

---

## 2. Prevenção Contra Secret Scanning (GitGuardian)

> [!CAUTION]
> **Atenção Estrita:** Nunca escreva senhas ou tokens com aparência real como literais estáticos de string no código de teste (ex.: `password = "senhaSegura123!"` ou `token = "eyJhbGciOi..."`).
> Isso pode acionar gatilhos de segurança do GitGuardian e bloquear pushes ou commits.

**Padrão Seguro Recomendado:**
Sempre crie funções auxiliares locais para gerar valores de teste dinamicamente em tempo de execução:
```dart
String _sampleToken() => ['mock', 'jwt', 'header', 'payload', 'sig'].join('.');
String _samplePassword() => ['Auth', 'Test', '123', '!'].join();
```

---

## 3. Tipos de Testes e Estrutura

### 3.1. Testes Unitários de Lógica Pura
- Localizados em `test/core/utils/` e `test/features/*/domain/`.
- Testam algoritmos de validação (ex.: `CnpjValidatorTest`), parsing de dados, transições permitidas da máquina de estados (`ObligationStatus.allowedTransitions`) e métodos de formatação.

### 3.2. Testes de Integração de Rede (Mocks de Camada de Dados)
- Localizados em `test/core/network/` e `test/features/*/data/`.
- Testam a montagem correta de requisições (`GET`, `POST`, `PUT`, `PATCH`, `multipartRequest`), injeção de cabeçalho `Authorization: Bearer <token>`, e parsing resiliente de DTOs e erros da API.

### 3.3. Testes de Controladores de Sessão e Estado
- Localizados em `test/features/*/presentation/controllers/`.
- Testam o ciclo de vida completo: `initialize`, `login`, `register` com auto-login, `logout` e interceptação de 401 via `handleUnauthorized`.

### 3.4. Testes de Widgets e Fluxos de Interface
- Testam renderização, comportamento dos formulários, máscaras, mensagens de validação inline, loading spinners, telas de erro com retry e guards de autenticação (`requireAuth`).

**Exemplo de Inicialização com Configuração de Janela:**
```dart
testWidgets('deve navegar entre as telas principais no layout desktop', (tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: MyPage(),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(MyPage), findsOneWidget);
});
```

---

## 4. Comandos de Verificação

Execute sempre a partir da pasta `frontend/`:

```bash
# 1. Executar análise estática de código (linter)
flutter analyze

# 2. Executar toda a suíte de testes automatizados
flutter test

# 3. Executar uma suíte específica
flutter test test/features/obligation/obligation_list_page_test.dart

# 4. Executar com cobertura
flutter test --coverage
```

