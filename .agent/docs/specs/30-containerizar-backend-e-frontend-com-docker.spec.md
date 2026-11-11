# SPEC-030 — Containerizar backend e frontend com Docker

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluído — Dockerfiles multi-stage para backend e frontend |
| Tipo | Diferencial (não obrigatório) — **Docker** |

## 1. Objetivo

Disponibilizar imagens Docker da API Spring Boot e do frontend Flutter Web, permitindo execução reprodutível sem JDK/Flutter instalados.

## 2. Situação atual

- Imagens multi-stage implementadas e funcionais em `backend/Dockerfile` e `frontend/Dockerfile`. **Concluído.**

## 3. Escopo funcional

- [x] `backend/Dockerfile` multi-stage: build com `eclipse-temurin:21-jdk` + Maven Wrapper; runtime com `eclipse-temurin:21-jre`; usuário não-root; `HEALTHCHECK` em `/actuator/health`.
- [x] Empacotamento executável com runtime otimizado.
- [x] `frontend/Dockerfile` multi-stage: build com Flutter Web SDK; runtime `nginx:alpine` servindo `build/web` com fallback SPA e compressão gzip.
- [x] `.dockerignore` em `backend/` e `frontend/` (excluindo `target/`, `build/`, `.env`, `uploads/`).
- [x] Variáveis via ambiente (`DB_URL`, `JWT_SECRET`, `STORAGE_LOCATION`, `SPRING_PROFILES_ACTIVE`, `API_URL`).

## 4. Regras e restrições

- Nenhum segredo embutido na imagem.
- Diretório de anexos montado como volume (não perder arquivos ao recriar o container).

## 5. Critérios de aceitação

- [x] `docker build` conclui para backend e frontend.
- [x] Container backend responde `UP` em `/actuator/health` conectado a um MySQL.
- [x] Container frontend serve a aplicação e consome a API.
- [x] README documenta build e execução.

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

