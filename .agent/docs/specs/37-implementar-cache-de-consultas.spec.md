# SPEC-037 — Implementar cache de consultas

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Cache** |

## 1. Objetivo

Reduzir consultas repetidas ao banco em leituras frequentes e pouco voláteis.

## 2. Situação atual

- **Ausente** — sem `spring-boot-starter-cache`, `@EnableCaching` ou `@Cacheable`.

## 3. Escopo funcional

- [ ] Adicionar `spring-boot-starter-cache` com Caffeine (TTL e tamanho máximo configuráveis em `application.yml`).
- [ ] Cachear `findById` de empresa e responsável e as listagens de ativos usadas nos dropdowns do formulário de obrigação.
- [ ] Invalidação (`@CacheEvict`/`@CachePut`) em create/update de empresa e responsável.
- [ ] Não cachear obrigações nem anexos (alta volatilidade/contagem de anexos).
- [ ] Desabilitar cache no perfil de testes quando necessário (`spring.cache.type=none`) e ter testes específicos de cache.
- [ ] Expor métricas de cache via Actuator (`/actuator/caches` ou métricas) apenas autenticado.
- [ ] Frontend (opcional): manter em memória a lista de empresas/responsáveis ativos durante a sessão, invalidando após cadastro/edição.

## 4. Regras e restrições

- Cache nunca deve retornar dado desatualizado após uma escrita na mesma instância.
- Objetos cacheados devem ser DTOs imutáveis, não entidades JPA.
- Documentar limitação: cache local não é compartilhado entre instâncias (Redis como melhoria futura).

## 5. Critérios de aceitação

- [ ] Segunda leitura não acessa o repositório (verificado com mock/spy).
- [ ] Após update, leitura retorna valor novo.
- [ ] Suíte backend verde.

## 6. Cenários de teste

- **Sucesso:** hit de cache em leituras repetidas.
- **Validação:** evict após inativação de empresa → dropdown não mostra empresa inativa.
- **Falha de dependência:** cache indisponível não quebra a requisição (fallback ao banco).
- **Regressão:** RN-006 (inativos sem novas atribuições) continua garantida.

## 7. Dependências

- SPEC-006, SPEC-007.

## 8. Pendências

- Definir TTL padrão (sugestão: 10 min).

## 9. Rastreabilidade

- `docs/arquitetura.md`, `README.md`.

