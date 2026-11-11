# Backend — API REST Player Contabilidade

Módulo backend da aplicação **Player Contabilidade**, desenvolvido em **Java 21 LTS** e **Spring Boot 3.x/4.x** com persistência em **MySQL 8.0** gerenciada por **Flyway**.

---

## 1. Arquitetura e Organização de Pacotes

A aplicação adota o padrão **Package by Feature** combinado com camadas estritas:

```text
backend/
├── src/main/java/dmptsystem/com/github/danieltsuzuki/playercontabilidadeback/
│   ├── auth/           # Autenticação e autocadastro de responsáveis (JWT)
│   ├── company/        # Gestão de Empresas clientes e validação de CNPJ
│   ├── responsible/    # Gestão de Responsáveis contábeis
│   ├── obligation/     # Obrigações fiscais e máquina de estados
│   ├── attachment/     # Anexos de comprovantes com storage local desacoplado
│   └── shared/         # Configurações transversais (Segurança, OpenAPI, Exception Handler)
├── src/main/resources/
│   ├── db/migration/   # Migrações Flyway (V1__create_schema.sql)
│   └── application.yml # Configurações da aplicação
├── src/test/java/      # Testes unitários, de controllers (WebMvc) e integração (Testcontainers)
└── pom.xml             # Dependências e plugins Maven (Spring Boot, JJWT, JaCoCo)
```

---

## 2. Requisitos e Configuração

### Pré-requisitos
- **JDK 21 LTS** configurado na máquina
- **Docker** e **Docker Compose** ativos para o banco MySQL

### Variáveis de Ambiente
O backend consome as variáveis de ambiente definidas no arquivo `.env` localizado na raiz do monorepo (`../.env`). Certifique-se de configurar o arquivo `.env` a partir de `.env.example`:

```bash
# Na raiz do monorepo:
cp .env.example .env
docker compose up -d
```

### Configuração de CORS (Cross-Origin Resource Sharing)
Para viabilizar requisições diretas de clientes web (como o Flutter Web executando em portas dinâmicas locais), o backend configura CORS no `SecurityConfig`:
- **Propriedade:** `cors.allowed-origin-patterns` (configurável via `CORS_ALLOWED_ORIGIN_PATTERNS` no `.env`, padrão `http://localhost:*,http://127.0.0.1:*`).
- Suporta credenciais (`allowCredentials: true`), todos os métodos HTTP (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `HEAD`), cabeçalhos abertos (`*`), cabeçalhos expostos (`Authorization`, `Content-Disposition`, `Location`) e resposta pública para requisições `OPTIONS /**`.

---

## 3. Como Executar

A partir deste diretório (`backend/`):

```bash
# Windows
.\mvnw.cmd spring-boot:run

# Linux / macOS
./mvnw spring-boot:run
```

Após a inicialização, a API estará acessível em `http://localhost:8080`.

---

## 4. Testes Automatizados e Cobertura

```bash
# Executar toda a suíte de testes (unitários + integração com Testcontainers)
# Windows
.\mvnw.cmd test

# Linux / macOS
./mvnw test

# Executar testes e verificar limites mínimos de cobertura (SPEC-040)
# Falha a compilação caso a cobertura caia abaixo dos limites configurados
# Windows
.\mvnw.cmd verify

# Linux / macOS
./mvnw verify
```

### Relatório e Metas de Cobertura JaCoCo (SPEC-040):
Após a execução dos testes, o relatório detalhado de cobertura de código estará disponível em:
`backend/target/site/jacoco/index.html`

O projeto possui regras automatizadas no plugin `jacoco-maven-plugin` vinculadas à fase `verify`:
- **Geral (BUNDLE):** mínimo de **85%** de linhas cobertas (atingido: **87.17%**).
- **Controllers:** mínimo de **90%** de linhas cobertas (atingido: **100.0%**).
- **Services:** mínimo de **90%** de linhas cobertas (atingido: **≥ 91.4% a 100%**).

---

## 5. Documentação Interativa da API (Swagger / OpenAPI)

Com o backend em execução:
- **Swagger UI:** [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON:** [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)

Para detalhes completos sobre contratos de endpoints, consulte [`../docs/api.md`](../docs/api.md).

