# SPEC-004 — Configurar MySQL e migrations com Flyway

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 4 |
| Card | [Configurar MySQL e migrations com Flyway](https://trello.com/c/9jS8YJYi) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Configurar conexão com MySQL e versionamento do schema por migrations.

## 2. Escopo funcional

- [ ] Configurar datasource via variáveis de ambiente.
- [ ] Criar migration inicial para company, users, obligation e attachment.
- [ ] Definir PKs, FKs, índices, constraints e timestamps.
- [ ] Garantir unicidade de CNPJ e e-mail.
- [ ] Não versionar credenciais.

## 3. Regras de negócio e restrições

- CNPJ é único no banco.
- E-mail é único no banco.
- FKs preservam integridade e não usam ON DELETE CASCADE.
- Credenciais não devem ser commitadas.
- Hibernate deve validar schema gerenciado pelo Flyway (`ddl-auto: validate`, conforme documentação).

## 4. Contratos e decisões técnicas

- MySQL 8 conforme changelog/testes.
- Flyway para migrations.
- Variáveis documentadas: DB_URL, DB_USERNAME, DB_PASSWORD.
- Schema físico descrito em docs/modelo-de-dados.md.

## 5. Critérios de aceitação

- [ ] Banco vazio é migrado automaticamente.
- [ ] Migrations executam em ordem.
- [ ] Constraints e índices são aplicados.
- [ ] Testes de integração verificam migration e unicidade.

## 6. Cenários de teste

- **Sucesso:** validar o fluxo principal descrito nesta SPEC.
- **Validação:** rejeitar dados obrigatórios ausentes ou inválidos.
- **Falha de dependência:** apresentar erro apropriado quando API, banco ou storage não estiver disponível, quando aplicável.
- **Regressão:** garantir que a funcionalidade não viole regras existentes do domínio.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`, quando aplicável.
- Modelo de dados em `docs/modelo-de-dados.md`, quando aplicável.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- A documentação do projeto descreve migration V1 e V2. Não renomear tabelas/colunas sem migration adicional.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/9jS8YJYi
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
