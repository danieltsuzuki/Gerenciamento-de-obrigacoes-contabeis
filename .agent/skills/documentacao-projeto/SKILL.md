---
name: documentacao-projeto
description: Cria, revisa e mantém documentação técnica alinhada ao código, migrations, testes, contratos da API e decisões arquiteturais. Use ao solicitar documentação ou ao alterar comportamento, dados, endpoints, segurança, configuração, dependências ou testes de regras.
---

# Skill — Documentação do projeto

## Princípio central
A documentação deve descrever o estado verificável do repositório. Inspecione código, migrations, configuração e testes antes de declarar algo implementado. Para regras pretendidas, use especificações/ADRs e marque claramente o que ainda não está implementado.

## Antes de editar
1. Leia `.agent/rules/03-documentacao-atualizada.md`.
2. Inspecione a estrutura atual de `docs/` e `README.md`.
3. Leia os arquivos afetados e as fontes de implementação correspondentes.
4. Preserve convenções e conteúdo válido; não substitua documentos inteiros por modelos genéricos.
5. Se código, migration, docs e ADR divergirem, registre a divergência e determine a fonte apropriada: migrations para estrutura real, código/testes para comportamento implementado, ADR para decisão arquitetural aceita. Não resolva contradições de negócio por suposição.

## Gatilhos de atualização

| Mudança | Documentos a revisar |
|---|---|
| Migration, tabela, coluna, índice, constraint ou relação | `modelo-de-dados.md` |
| Regra de negócio/validação | `regras-de-negocio.md` e `status-implementacao.md` |
| Enum, transição ou data de conclusão | `ciclo-de-vida-obrigacao.md` e `regras-de-negocio.md` |
| Controller, rota, DTO, payload, status HTTP ou erro | `api.md` |
| Camada, pacote, integração ou storage | `arquitetura.md` e ADR se houver decisão |
| Segurança, JWT, política de acesso | `api.md`, `arquitetura.md` e testes pertinentes |
| Configuração, variável de ambiente, comando ou dependência | `README.md` |
| Nova cobertura de teste para regra | `status-implementacao.md` |
| Qualquer mudança funcional | `CHANGELOG.md` |

## Fluxo de atualização
1. Identifique o diff (`git diff --stat` e `git diff`) ou os arquivos efetivamente alterados.
2. Atualize apenas os documentos afetados.
3. Atualize `status-implementacao.md` com estado, arquivos de implementação e testes que realmente existem.
4. Acrescente entrada no `CHANGELOG.md`, mais recente no topo, descrevendo impacto para quem usa ou mantém o sistema.
5. Atualize `docs/index.md` se criar, remover ou renomear documentos.
6. Registre decisões arquiteturais duradouras em ADR separado. Não transforme perguntas abertas em decisões.
7. Execute o verificador disponível:
   `python .agent/skills/documentacao-projeto/scripts/check_docs.py`
8. Se o verificador falhar, investigue; corrija documentação ou implementação conforme a fonte correta. Informe limitações se não puder executar.

## Status permitidos
Use a taxonomia já adotada pelo projeto. Quando ausente, diferencie claramente `Planejado`, `Em andamento`, `Implementado` e `Testado`. `Testado` exige teste existente e aprovado; não basta haver código.

## Estilo
- Escreva em português claro; preserve nomes técnicos, classes, tabelas, campos e rotas em inglês.
- Use identificadores estáveis para regras (`RN-001` etc.); não renumere regras existentes.
- Use Mermaid para diagramas versionáveis.
- Evite duplicar conteúdo: detalhe uma regra em um documento e referencie-o nos demais.
- Não inclua segredos, tokens, senhas reais ou dados pessoais.
- Marque lacunas como `A confirmar:` com a pergunta objetiva.

## Estrutura e modelos
Consulte `references/estrutura-docs.md` antes de criar novos documentos. Adapte o modelo à estrutura já existente; não crie arquivos vazios só para cumprir uma lista ideal.
