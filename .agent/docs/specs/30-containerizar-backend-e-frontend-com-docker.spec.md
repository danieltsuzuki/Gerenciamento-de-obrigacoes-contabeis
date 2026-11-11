# SPEC-030 — Containerizar backend e frontend com Docker

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Docker** |

## 1. Objetivo

Disponibilizar imagens Docker da API Spring Boot e do frontend Flutter Web, permitindo execução reprodutível sem JDK/Flutter instalados.

## 2. Situação atual

- `Dockerfile` na raiz apenas estende `mysql:8.0` (não empacota a aplicação). **Parcial.**

## 3. Escopo funcional

- [ ] `backend/Dockerfile` multi-stage: build com `eclipse-temurin:21-jdk` + Maven Wrapper; runtime com `eclipse-temurin:21-jre`; usuário não-root; `HEALTHCHECK` em `/actuator/health`.
- [ ] Empacotamento executável (avaliar troca de `war` para `jar` ou execução do `war` embarcado).
- [ ] `frontend/Dockerfile` multi-stage: build `flutter build web --dart-define=API_URL=...`; runtime `nginx:alpine` servindo `build/web` com fallback SPA.
- [ ] `.dockerignore` em `backend/` e `frontend/` (excluir `target/`, `build/`, `.env`, `uploads/`).
- [ ] Renomear/mover o `Dockerfile` atual de MySQL ou removê-lo se substituído pela imagem oficial no Compose.
- [ ] Variáveis via ambiente (`DB_URL`, `JWT_SECRET`, `STORAGE_LOCATION`, `SPRING_PROFILES_ACTIVE`).

## 4. Regras e restrições

- Nenhum segredo embutido na imagem.
- Diretório de anexos montado como volume (não perder arquivos ao recriar o container).

## 5. Critérios de aceitação

- [ ] `docker build` conclui para backend e frontend.
- [ ] Container backend responde `UP` em `/actuator/health` conectado a um MySQL.
- [ ] Container frontend serve a aplicação e consome a API.
- [ ] README documenta build e execução.

## 6. Cenários de teste

- **Sucesso:** build e run locais.
- **Falha de dependência:** backend sem banco → healthcheck `DOWN`/container reinicia.
- **Regressão:** execução local sem Docker continua funcionando.

## 7. Dependências

- SPEC-003, SPEC-004, SPEC-013.

## 8. Pendências

- Definir registro de imagens (GHCR) — ver SPEC-039.

## 9. Rastreabilidade

- `README.md`, `docker-compose.yml`.

