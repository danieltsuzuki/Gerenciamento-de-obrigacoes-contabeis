# Pendências e Perguntas em Aberto

## Perguntas de Negócio para Fases Futuras (Pós-MVP)

- **Anexos em Obrigações Concluídas:** Pode remover ou substituir anexos de uma obrigação no status `COMPLETED`, ou o histórico torna-se 100% imutável?
- **Autorização por Perfil (RBAC):** Haverá diferenciação de permissões (ex.: perfil Administrador vs Operador, ou validação se apenas o responsável atribuído pode avançar o status da obrigação) ou mantém-se apenas autenticação JWT?
- **Recorrência de Obrigações:** A obrigação terá suporte a periodicidade automática (mensal, trimestral, anual gerada por job agendado) ou cada obrigação continuará sendo avulsa?
- **Status Derivado "Atrasada":** Haverá exibição visual no frontend destacando prazo vencido calculado dinamicamente em consulta (`dueDate < hoje` e status != `COMPLETED`), sem necessidade de novo valor no enum?
- **CNPJ Alfanumérico da Receita Federal:** A especificação atual exige apenas números (14 dígitos). Quando o formato alfanumérico da Receita Federal entrar em vigor, o validador isolado `Cnpj` deverá ser estendido.

## Itens Técnicos Resolvidos no MVP

- **Autenticação:** Resolvida via Spring Security e JJWT (tokens Bearer stateless, BCrypt para senhas e rotas de login/registro).
- **Validações:** Resolvidas com Bean Validation e classes de domínio dedicadas (`Cnpj`, `@ValidCnpj`, `@Email`).
- **Filtros de Vencimento:** Resolvidos com parâmetros de consulta inclusivos `dueFrom` e `dueTo` (`LocalDate`).
- **Arquitetura de Anexos:** Resolvida com `LocalFileSystemStorage`, prevenção de *Path Traversal*, limite de 10MB e compensação transacional.
- **Estratégia de Testes:** Resolvida com testes de unidade rápidos e testes de integração com Testcontainers MySQL 8.
