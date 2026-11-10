# Documentação sempre atualizada

Ao concluir qualquer **SPEC** (especificação funcional/técnica) ou qualquer tarefa que altere entidades, migrations, constraints, regras de negócio, status/transições, controllers, DTOs, endpoints, segurança, storage, configuração, dependências, componentes ou testes:

1. **Atualizar a SPEC e seu índice:**
   - No arquivo da própria especificação (`.agent/docs/specs/<spec>.spec.md`), atualizar o campo `Situação da especificação` para concluído e marcar os itens de escopo funcional e critérios de aceitação como concluídos (`[x]`).
   - Atualizar o sumário de status em `.agent/docs/specs/README.md`.

2. **Acionar a Skill `documentacao-projeto` e atualizar os documentos afetados:**
   - Revisar e atualizar sempre `docs/status-implementacao.md` (rastreabilidade de regras e módulos testados) e `docs/CHANGELOG.md` (com as entregas da SPEC descritas sob `### Adicionado` ou `### Alterado`).
   - Atualizar `docs/api.md` para mudanças de rota, payload, resposta, autenticação ou erro.
   - Atualizar `docs/modelo-de-dados.md` para migrations, tabelas, colunas, índices, constraints ou relacionamentos.
   - Atualizar `docs/arquitetura.md` quando houver novas camadas, componentes, estruturas de pacotes ou decisões técnicas.
   - Atualizar os arquivos `README.md` (raiz, `frontend/README.md` e `backend/README.md`) sempre que novos recursos, comandos de execução, configurações ou dependências forem introduzidos.

3. **Validação automatizada:**
   - Execute `python .agent/skills/documentacao-projeto/scripts/check_docs.py .` na raiz do projeto, se o script estiver presente e aplicável. Corrija divergências reais; não altere código apenas para satisfazer um verificador sem investigar.

4. **Transparência e Integridade:**
   - No resumo final, informe explicitamente todos os documentos atualizados e os testes/verificações executados.
   - Nunca registre como implementado/testado algo que não esteja comprovado pelo código e pelos testes executados com sucesso. Marque dúvidas como `A confirmar:` e preserve perguntas em aberto.
