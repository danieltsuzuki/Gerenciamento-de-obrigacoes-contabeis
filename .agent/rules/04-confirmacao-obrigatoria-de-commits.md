# Confirmação obrigatória para commits e push

Esta regra estabelece o protocolo estrito de versionamento para o assistente de desenvolvimento neste projeto:

1. **Proibição de commits automáticos:**
   - O agente **NUNCA** deve executar comandos `git commit` ou `git push` por iniciativa própria ou como parte automática da conclusão de uma tarefa, a menos que o usuário tenha solicitado explicitamente no prompt atual (ex.: "faça o commit", "commite as alterações", "git push").

2. **Fluxo obrigatório ao finalizar tarefas:**
   - Conclua as implementações, refatorações e testes necessários.
   - Mantenha a documentação sincronizada conforme a regra `03-documentacao-atualizada.md`.
   - Apresente ao usuário o resumo das alterações realizadas (`git status`), indicando os arquivos criados e modificados.
   - Sugira a mensagem de commit apropriada (seguindo o padrão *Conventional Commits* em inglês ou português conforme padrão do repositório) e a branch de destino.
   - **Aguarde a confirmação expressa do usuário** antes de executar `git commit` ou `git push`.

3. **Solicitações de desenvolvimento genéricas:**
   - Quando o usuário solicitar comandos como "desenvolva a spec X", "corrija o erro Y" ou "crie o componente Z", o agente deve implementar, testar e documentar, mas **parar antes de commitar**, exibindo o resumo e perguntando se o usuário deseja efetuar o commit.

