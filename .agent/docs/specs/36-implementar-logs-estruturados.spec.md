# SPEC-036 — Implementar logs estruturados e rastreabilidade de requisições

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Logs** |

## 1. Objetivo

Adicionar logging consistente na API para diagnóstico e operação.

## 2. Situação atual

- **Ausente** — nenhuma classe de `backend/src/main` declara logger (SLF4J); apenas logs padrão do framework.

## 3. Escopo funcional

- [ ] Filtro `RequestLoggingFilter` registrando método, caminho, status e duração de cada requisição.
- [ ] Correlation ID: ler/gerar `X-Request-Id`, propagar via MDC e devolver no header de resposta (expor no CORS).
- [ ] Logs de negócio em nível `INFO` nos serviços: criação/edição de empresa, responsável, obrigação; transições de status; upload/download de anexos.
- [ ] `GlobalExceptionHandler`: `WARN` para erros 4xx de negócio e `ERROR` com stack trace para 5xx (`STORAGE_ERROR`, inesperados).
- [ ] Logs de segurança: falha de login (sem registrar senha), token inválido/expirado.
- [ ] Configuração por perfil: texto legível em `dev`; JSON estruturado em `prod` (Logback / `logging.structured.format.console`).
- [ ] Nunca registrar senha, hash, token JWT completo ou conteúdo de arquivos.
- [ ] Documentar níveis e formato no README.

## 4. Regras e restrições

- Dados sensíveis mascarados (e-mail pode ser parcialmente mascarado em logs de falha de login).
- Logs não podem alterar o contrato da API.

## 5. Critérios de aceitação

- [ ] Toda resposta contém `X-Request-Id`.
- [ ] Teste unitário garantindo que senha/token não aparecem nos logs (ex.: `OutputCaptureExtension`).
- [ ] Testes existentes continuam verdes.

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

