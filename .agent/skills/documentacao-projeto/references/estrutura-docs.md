# Referência de estrutura documental

Use como orientação, não como obrigação de criar todos os arquivos.

## Mapa sugerido
- `README.md`: propósito, funcionalidades disponíveis, stack verificada, pré-requisitos, configuração, comandos e link para docs.
- `docs/index.md`: índice da documentação.
- `docs/arquitetura.md`: camadas, pacotes, integrações e decisões.
- `docs/modelo-de-dados.md`: ER, tabelas, colunas, índices e constraints derivados das migrations.
- `docs/regras-de-negocio.md`: regras numeradas e estado.
- `docs/ciclo-de-vida-obrigacao.md`: estados, transições e efeitos.
- `docs/api.md`: endpoints, payloads, autenticação, paginação e erros.
- `docs/status-implementacao.md`: regra → implementação → teste.
- `docs/CHANGELOG.md`: histórico de mudanças.
- `docs/decisoes/ADR-NNNN-*.md`: decisões arquiteturais.

## Cuidados
- Crie somente documentos relevantes ao projeto e mantenha o padrão já adotado.
- Modelo de dados deve ser derivado das migrations reais; não de um exemplo de código ou memória.
- Contratos API devem ser conferidos com controllers, DTOs e testes.
- Status de implementação deve refletir evidência real.
- ADR registra decisão aceita, contexto, consequências e alternativas; questões em aberto ficam em documento de pendências.
- Use links relativos válidos e atualize `docs/index.md` ao adicionar/renomear arquivos.
