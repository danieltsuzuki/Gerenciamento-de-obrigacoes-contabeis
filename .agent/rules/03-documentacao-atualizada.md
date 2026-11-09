# Documentação sempre atualizada

Ao concluir qualquer tarefa que altere entidades, migrations, constraints, regras de negócio, status/transições, controllers, DTOs, endpoints, segurança, storage, configuração, dependências ou testes de regra:

1. Acione a Skill `documentacao-projeto`.
2. Atualize somente os documentos afetados, mas sempre revise `docs/status-implementacao.md` e `docs/CHANGELOG.md` quando houver mudança funcional.
3. Atualize `docs/api.md` para mudanças de rota, payload, resposta, autenticação ou erro.
4. Atualize `docs/modelo-de-dados.md` para migrations, tabelas, colunas, índices, constraints ou relacionamentos.
5. Atualize a matriz regra → implementação → teste quando regra ou cobertura mudar.
6. Execute `python .agent/skills/documentacao-projeto/scripts/check_docs.py` na raiz do projeto, se o script estiver presente e aplicável. Corrija divergências reais; não altere código apenas para satisfazer um verificador sem investigar.
7. No resumo final, informe os documentos atualizados e os testes/verificações executados.

Nunca registre como implementado/testado algo que não esteja comprovado pelo código e pelos testes. Marque dúvidas como `A confirmar:` e preserve perguntas em aberto.
