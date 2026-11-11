# SPEC-031 — Orquestrar a stack completa com Docker Compose

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Docker Compose** |

## 1. Objetivo

Subir banco, API e frontend com um único `docker compose up`.

## 2. Situação atual

- `docker-compose.yml` contém somente o serviço `mysql`. **Parcial.**

## 3. Escopo funcional

- [ ] Serviço `mysql` com `healthcheck` (`mysqladmin ping`).
- [ ] Serviço `backend` (imagem da SPEC-030) com `depends_on: mysql: condition: service_healthy`, variáveis do `.env` e volume `uploads_data`.
- [ ] Serviço `frontend` (Nginx) exposto em porta configurável (`FRONTEND_PORT`, padrão `8081`).
- [ ] Profiles: `infra` (apenas MySQL, fluxo atual de desenvolvimento) e `full` (stack completa).
- [ ] Atualizar `.env.example` com novas variáveis (`BACKEND_PORT`, `FRONTEND_PORT`).
- [ ] Ajustar `CORS_ALLOWED_ORIGIN_PATTERNS` para a origem do frontend containerizado.

## 4. Regras e restrições

- Compatível com o fluxo atual (`docker compose up -d` sobe só o MySQL ou documentar a mudança).
- Volumes nomeados para dados do MySQL e anexos.

## 5. Critérios de aceitação

- [ ] `docker compose --profile full up -d` deixa os 3 serviços saudáveis.
- [ ] Flyway aplica migrations automaticamente na primeira subida.
- [ ] Fluxo ponta a ponta (login → cadastrar empresa → obrigação → anexo) funciona via navegador.

## 6. Cenários de teste

- **Sucesso:** subida limpa sem volumes existentes.
- **Falha de dependência:** MySQL lento → backend aguarda healthcheck.
- **Regressão:** `docker compose up -d` (perfil infra) continua atendendo testes locais.

## 7. Dependências

- SPEC-030.

## 8. Pendências

- Nenhuma.

## 9. Rastreabilidade

- `docker-compose.yml`, `.env.example`, `README.md`.

