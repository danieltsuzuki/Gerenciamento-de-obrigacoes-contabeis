# Pendências e Perguntas em Aberto

## Decisões de Negócio Consolidadas (Resolvidas na SPEC-041)

- **Anexos em Obrigações Concluídas:** O histórico de uma obrigação no status `COMPLETED` é **100% imutável**. Não é permitido anexar novos arquivos (retorna HTTP 422 `OBLIGATION_COMPLETED`). Apenas o download e a consulta de anexos existentes permanecem disponíveis.
- **Autorização por Perfil / Responsabilidade:** **Apenas o usuário responsável atribuído à obrigação pode avançar o seu status**. Tentativas de alteração de status por outros usuários retornam HTTP 403 `FORBIDDEN`. Na interface, ações de alteração de status ficam bloqueadas para outros usuários.
- **Recorrência de Obrigações:** **Não haverá recorrência automática no escopo deste MVP**. Todas as obrigações são avulsas.
- **Status Derivado "Atrasada":** **Exibição visual dinâmica no frontend** destacando prazos vencidos (`dueDate < hoje` e `status != COMPLETED`) via badge/chip de alerta, sem criação de novo valor no enum do banco de dados (que permanece com `PENDING`, `IN_PROGRESS` e `COMPLETED`).
- **CNPJ Alfanumérico da Receita Federal:** **Validação e suporte pleno tanto ao formato numérico clássico (14 dígitos) quanto ao novo formato alfanumérico da Receita Federal**, com cálculo ponderado módulo 11 adaptado para valores ASCII.

## Itens Técnicos Resolvidos no MVP

- **Autenticação:** Resolvida via Spring Security e JJWT (tokens Bearer stateless, BCrypt para senhas e rotas de login/registro).
- **Validações:** Resolvidas com Bean Validation e classes de domínio dedicadas (`Cnpj`, `@ValidCnpj`, `@Email`).
- **Filtros de Vencimento:** Resolvidos com parâmetros de consulta inclusivos `dueFrom` e `dueTo` (`LocalDate`).
- **Arquitetura de Anexos:** Resolvida com `LocalFileSystemStorage`, prevenção de *Path Traversal*, limite de 10MB e compensação transacional.
- **Estratégia de Testes:** Resolvida com testes de unidade rápidos e testes de integração com Testcontainers MySQL 8.
- **Regras e Refinamentos de Domínio:** Especificados na [SPEC-041](../.agent/docs/specs/41-regras-negocio-pendencias-e-perguntas-em-aberto.spec.md).
