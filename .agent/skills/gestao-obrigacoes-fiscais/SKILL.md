---
name: gestao-obrigacoes-fiscais
description: Orienta tarefas de análise, implementação, correção, revisão e testes do sistema de gestão de obrigações contábeis/fiscais, incluindo Company, Responsible, Obligation, Attachment, regras de domínio, MySQL/Flyway, Spring Boot, API REST, JWT e armazenamento de anexos. Use para qualquer tarefa que altere ou dependa desses conceitos.
---

# Skill — Gestão de obrigações contábeis/fiscais

Use esta Skill para trabalhar no domínio e no backend documentado. Ela não autoriza inventar funcionalidades nem substituir o estado real do repositório.

## Antes de agir
1. Leia as Rules aplicáveis em `.agent/rules/`.
2. Inspecione o repositório: `pom.xml`/build, pacote base, migrations, entidades, repositories, serviços, controllers, DTOs, configuração de segurança, storage e testes.
3. Consulte os documentos pertinentes:
   - `references/domain-model.md`: entidades, colunas, constraints e relações.
   - `references/lifecycle.md`: estados e transições.
   - `references/implementation-guide.md`: camadas, API, segurança, anexos e testes.
   - `docs/api.md`: contrato HTTP vigente.
   - `docs/status-implementacao.md`: situação documentada das regras.
   - ADRs: decisões arquiteturais aceitas.
4. Diferencie sempre comportamento implementado, comportamento documentado e proposta.

## Stack e limites
A documentação do projeto identifica Java 21, Spring Boot, Spring Data JPA, MySQL 8, Flyway, Spring Security/JWT, BCrypt, JUnit/Mockito e Testcontainers MySQL 8. Confirme versões e dependências no repositório antes de assumir versões exatas ou adicionar dependências.

O escopo documentado nesta Skill é principalmente backend. Não imponha arquitetura, gerenciamento de estado, roteador ou bibliotecas Flutter: os documentos de referência fornecidos não definem esses detalhes.

## Sequência recomendada
1. Entenda o fluxo existente e evite recriar código.
2. Para alteração persistente, planeje migration compatível e atualização do modelo.
3. Implemente regra no domínio/serviço apropriado; mantenha controller fino e DTOs como fronteira HTTP.
4. Preserve invariantes de domínio e contrato da API.
5. Escreva/ajuste testes no mesmo ciclo da implementação.
6. Atualize documentação com `documentacao-projeto`.
7. Execute testes relevantes e, quando viável, suíte completa; reporte limitações ambientais.

## Critérios de qualidade
- Repositories não expõem métodos de exclusão.
- Integridade é protegida no banco e na aplicação.
- Não exponha entidades ou hashes de senha na API.
- Regras de transição estão centralizadas no domínio.
- Operações de arquivo são seguras e tratam falhas parciais.
- Testes cobrem caminhos válidos, inválidos e casos-limite.
- Não marque como concluído algo não verificado.

## Questões que exigem decisão
Consulte `references/open-questions.md`. Se a tarefa depender de um item pendente, pergunte antes de escolher uma política.
