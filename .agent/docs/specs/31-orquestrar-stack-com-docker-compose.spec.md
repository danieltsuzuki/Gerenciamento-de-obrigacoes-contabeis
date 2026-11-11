# SPEC-031 — Orquestrar a stack completa com Docker Compose

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — stack completa orquestrada via Docker Compose |
| Tipo | Diferencial (não obrigatório) — **Docker Compose** |

## 1. Objetivo

Subir banco, API e frontend com um único `docker compose up`.

## 2. Situação atual

- `docker-compose.yml` orquestra MySQL 8.0, Backend Spring Boot e Frontend Flutter Web com suporte a perfis `infra` e `full`. **Concluído.**

## 3. Escopo funcional

- [x] Serviço `mysql` com `healthcheck` (`mysqladmin ping`).
- [x] Serviço `backend` (imagem da SPEC-030) com `depends_on: mysql: condition: service_healthy`, variáveis do `.env` e volume `uploads_data`.
- [x] Serviço `frontend` (Nginx) exposto em porta configurável (`FRONTEND_PORT`, padrão `8081`).
- [x] Profiles: default/infra (MySQL para desenvolvimento local) e `full` (stack completa).
- [x] Atualizar `.env.example` com novas variáveis (`BACKEND_PORT`, `FRONTEND_PORT`).
- [x] Ajustar `CORS_ALLOWED_ORIGIN_PATTERNS` para a origem do frontend containerizado.

## 4. Regras e restrições

- Compatível com o fluxo atual (`docker compose up -d` sobe o MySQL).
- Volumes nomeados para dados do MySQL e anexos.

## 5. Critérios de aceitação

- [x] `docker compose --profile full up -d` deixa os 3 serviços operacionais.
- [x] Flyway aplica migrations automaticamente na primeira subida.
- [x] Fluxo ponta a ponta (login → cadastrar empresa → obrigação → anexo) funciona via navegador.

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

