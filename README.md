# Player Contabilidade Back

API backend para gerenciamento de obrigações fiscais, empresas clientes, responsáveis e controle de prazos e anexos para contabilidade.

## Funcionalidades
- **Infraestrutura de Banco de Dados**: Versionamento de esquema via Flyway (`V1__create_schema.sql`).
- **Segurança de Configuração**: Parametrização estrita por variáveis de ambiente, sem credenciais expostas no código ou repositório.
- **Validação de Integridade**: Constraints de unicidade para CNPJ e e-mail, integridade referencial sem exclusão em cascata (preservação do histórico fiscal).
- *[Planejado]* Cadastro e validação de Empresas (`Company`) com validação de dígitos verificadores de CNPJ.
- *[Planejado]* Gestão de Responsáveis (`User`) com hash de senhas e controle de ativação.
- *[Planejado]* Ciclo de vida de Obrigações Fiscais (`Obligation`: `PENDING` -> `IN_PROGRESS` -> `COMPLETED`).
- *[Planejado]* Gestão de Anexos (`Attachment`) com armazenamento em filesystem/object storage.

## Stack
- **Java 21**
- **Spring Boot 3.x / 4.x** (Web, Data JPA, Validation)
- **MySQL 8.0**
- **Flyway** (Gerenciamento e migração de banco)
- **Maven** (Build e gerenciamento de dependências)
- **Testcontainers** (Testes de integração com container real MySQL 8)

---

## Como rodar

### Pré-requisitos
- **JDK 21** instalado e configurado no PATH
- **Docker** e **Docker Compose** em execução
- **Git**

### Configuração (Variáveis de Ambiente)
A aplicação lê as credenciais de banco diretamente do ambiente. Por segurança, nenhuma senha ou usuário possui valor padrão no código.

Crie o seu arquivo `.env` a partir do modelo fictício versionado:
```bash
cp .env.example .env
```

| Variável | Descrição | Exemplo / Padrão |
|---|---|---|
| `DB_PORT` | Porta exposta pelo container MySQL | `3306` |
| `DB_NAME` | Nome do banco de dados | `player_contabilidade` |
| `DB_USERNAME` | Usuário do banco de dados | `player_user` |
| `DB_PASSWORD` | Senha do usuário do banco de dados | `player_secret_password` |
| `DB_ROOT_PASSWORD` | Senha do usuário root do MySQL (container) | `player_root_password` |
| `DB_URL` | JDBC URL de conexão com o banco | `jdbc:mysql://localhost:3306/player_contabilidade?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true` |

#### Como definir as variáveis no seu ambiente:
1. **Via arquivo `.env` (recomendado para Docker Compose e ferramentas locais):**
   O arquivo `.env` é lido automaticamente pelo Docker Compose e pode ser carregado pela sua IDE.
2. **Via terminal (PowerShell):**
   ```powershell
   $env:DB_USERNAME="player_user"
   $env:DB_PASSWORD="player_secret_password"
   $env:DB_URL="jdbc:mysql://localhost:3306/player_contabilidade?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
   ```
3. **Via terminal (Bash / Zsh):**
   ```bash
   export DB_USERNAME=player_user
   export DB_PASSWORD=player_secret_password
   export DB_URL="jdbc:mysql://localhost:3306/player_contabilidade?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
   ```
4. **Via IDE:**
   - **IntelliJ IDEA**: Em *Run/Debug Configurations* -> *Environment variables*, adicione as chaves `DB_USERNAME`, `DB_PASSWORD`, `DB_URL`.
   - **VS Code**: Adicione a seção `envFile: "${workspaceFolder}/.env"` no seu arquivo `launch.json`.

---

### Comandos

#### 1. Subir o banco de dados MySQL em Docker
```bash
docker compose up -d
```
Para verificar se o container subiu corretamente:
```bash
docker ps
```

#### 2. Executar a aplicação
Com as variáveis de ambiente definidas:
```bash
# Windows
.\mvnw.cmd spring-boot:run

# Linux / macOS
./mvnw spring-boot:run
```

#### 3. Executar os testes de integração (Testcontainers)
Os testes de integração utilizam o Testcontainers para instanciar dinamicamente um container isolado de MySQL 8 e validar a aplicação das migrations e constraints de integridade:
```bash
# Windows
.\mvnw.cmd test

# Linux / macOS
./mvnw test
```

---

## Documentação do Projeto
A documentação detalhada do sistema está estruturada na pasta `docs/`:
- [Mapa da Documentação](docs/index.md)
- [Modelo de Dados e Diagrama ER](docs/modelo-de-dados.md)
- [Status de Implementação das Regras](docs/status-implementacao.md)
- [Changelog](docs/CHANGELOG.md)

