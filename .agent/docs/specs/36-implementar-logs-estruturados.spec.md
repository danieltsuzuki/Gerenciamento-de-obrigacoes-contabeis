# SPEC-036 — Implementar logs estruturados e rastreabilidade de requisições

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Aprovada |
| Tipo | Diferencial (não obrigatório) — **Logs** |

## 1. Objetivo

Adicionar logging consistente na API para diagnóstico e operação.

## 2. Situação atual

- **Concluído** — logs estruturados implementados com `RequestLoggingFilter`, correlation ID (`X-Request-Id`), MDC, logs de negócio nos serviços, mascaramento seguro e JSON ECS em produção.

## 3. Escopo funcional

- [x] Filtro `RequestLoggingFilter` registrando método, caminho, status e duração de cada requisição.
- [x] Correlation ID: ler/gerar `X-Request-Id`, propagar via MDC e devolver no header de resposta (expor no CORS).
- [x] Logs de negócio em nível `INFO` nos serviços: criação/edição de empresa, responsável, obrigação; transições de status; upload/download de anexos.
- [x] `GlobalExceptionHandler`: `WARN` para erros 4xx de negócio e `ERROR` com stack trace para 5xx (`STORAGE_ERROR`, inesperados).
- [x] Logs de segurança: falha de login (sem registrar senha), token inválido/expirado.
- [x] Configuração por perfil: texto legível em `dev`; JSON estruturado em `prod` (Logback / `logging.structured.format.console: ecs`).
- [x] Nunca registrar senha, hash, token JWT completo ou conteúdo de arquivos.
- [x] Documentar níveis e formato no README e `docs/api.md`.

## 4. Regras e restrições

- Dados sensíveis mascarados (e-mail pode ser parcialmente mascarado em logs de falha de login).
- Logs não podem alterar o contrato da API.

## 5. Critérios de aceitação

- [x] Toda resposta contém `X-Request-Id`.
- [x] Teste unitário garantindo que senha/token não aparecem nos logs (ex.: `OutputCaptureExtension`).
- [x] Testes existentes continuam verdes.

## 6. Cenários de teste

- **Sucesso:** requisição gera log com request id, status e duração.
- **Validação:** erro 400 gera `WARN` sem stack trace.
- **Falha de dependência:** falha de storage gera `ERROR` com stack trace.
- **Regressão:** contrato de erro padronizado inalterado.

## 7. Dependências

- SPEC-011.

## 8. Pendências

- Destino de logs em produção (stdout + agregador).

## 9. Rastreabilidade

- `README.md`, `docs/arquitetura.md`.

