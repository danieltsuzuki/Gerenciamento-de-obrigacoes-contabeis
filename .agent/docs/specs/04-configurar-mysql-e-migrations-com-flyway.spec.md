# SPEC-004 — Configurar MySQL e migrations com Flyway

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 4 |
| Card | [Configurar MySQL e migrations com Flyway](https://trello.com/c/9jS8YJYi) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída — migrations V1 e V2 aplicadas e validadas com Testcontainers |

## 1. Objetivo

Configurar conexão com MySQL e versionamento do schema por migrations.

## 2. Escopo funcional

- [x] Configurar datasource via variáveis de ambiente (`application.yml`, `.env.example`).
- [x] Criar migration inicial para company, users, obligation e attachment (`V1__create_schema.sql`, `V2__align_domain_names.sql`).
- [x] Definir PKs, FKs, índices, constraints e timestamps (`V1__create_schema.sql`).
- [x] Garantir unicidade de CNPJ e e-mail (`uk_company_cnpj`, `uk_users_email`).
- [x] Não versionar credenciais (`.gitignore`, sem senhas hardcoded).

## 3. Regras de negócio e restrições

- CNPJ é único no banco (`uk_company_cnpj`, RN-002).
- E-mail é único no banco (`uk_users_email`, RN-003).
- FKs preservam integridade e não usam ON DELETE CASCADE (RN-005).
- Credenciais não devem ser commitadas.
- Hibernate deve validar schema gerenciado pelo Flyway (`ddl-auto: validate`, conforme documentação).

## 4. Contratos e decisões técnicas

- MySQL 8.0 gerenciado via Docker Compose e Testcontainers nos testes de integração.
- Flyway para controle de versão e migração (`src/main/resources/db/migration`).
- Variáveis documentadas: DB_PORT, DB_NAME, DB_USERNAME, DB_PASSWORD, DB_ROOT_PASSWORD, DB_URL.
- Schema físico descrito em `docs/modelo-de-dados.md`.

## 5. Critérios de aceitação

- [x] Banco vazio é migrado automaticamente (validado em `DatabaseMigrationIntegrationTest`).
- [x] Migrations executam em ordem (V1 e V2 versionadas e aplicadas sequencialmente).
- [x] Constraints e índices são aplicados (validado em `DomainPersistenceIntegrationTest`).
- [x] Testes de integração verificam migration e unicidade (`DatabaseMigrationIntegrationTest`).

## 6. Cenários de teste

- **Sucesso:** validar aplicação de migrations V1 e V2 em banco vazio (`DatabaseMigrationIntegrationTest#shouldApplyMigrationOnEmptyDatabase`).
- **Validação:** rejeitar duplicidade de CNPJ (`shouldRejectDuplicateCnpj`) e de e-mail (`shouldRejectDuplicateEmail`).
- **Falha de dependência:** integridade referencial sem cascade rejeita deleção de entidade pai com filhos (`shouldRefuseToDeleteCompanyWithObligations`).
- **Regressão:** validar compatibilidade com Hibernate em modo `ddl-auto: validate` (`DomainPersistenceIntegrationTest`).

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Modelo de dados em `docs/modelo-de-dados.md`.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- A documentação do projeto descreve migration V1 e V2 aplicadas. Novas alterações estruturais devem ser adicionadas como novas migrations (ex.: `V3__...`).

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/9jS8YJYi
- Documentação de referência: `docs/modelo-de-dados.md`, `docs/arquitetura.md`, `docs/index.md`, `docs/api.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs.
