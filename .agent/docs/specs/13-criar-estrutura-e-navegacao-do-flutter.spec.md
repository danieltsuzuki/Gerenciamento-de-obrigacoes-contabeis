# SPEC-013 — Criar estrutura e navegação do Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 13 |
| Card | [Criar estrutura e navegação do Flutter](https://trello.com/c/gap9zScy) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Concluído — implementado e testado |

## 1. Objetivo

Criar o aplicativo Flutter, sua estrutura por features e a navegação entre telas principais.

## 2. Escopo funcional

- [x] Criar projeto Flutter e configurar ambientes.
- [x] Organizar features companies, responsibles e obligations.
- [x] Separar camadas data/domain/presentation.
- [x] Configurar roteamento, tema e componentes compartilhados.
- [x] Definir estados de loading, erro e vazio reutilizáveis.
- [x] Configurar cliente HTTP e base URL por ambiente.

## 3. Regras de negócio e restrições

- A interface não deve concentrar chamadas HTTP diretamente nos widgets.
- URL da API deve ser configurável por ambiente.
- Estados de loading/erro/vazio devem ter tratamento consistente.

## 4. Contratos e decisões técnicas

- Flutter 3.29+ / Dart 3.7+; organização por features; camadas data/domain/presentation.
- Features iniciais: companies, responsibles, obligations.
- Cliente HTTP configurado para backend Spring Boot com mapeamento de ApiException.

## 5. Critérios de aceitação

- [x] App inicia sem erros.
- [x] Navegação entre telas principais funciona.
- [x] Tema e componentes compartilhados estão configurados.
- [x] Base URL não está hardcoded em widgets.

## 6. Cenários de teste

- **Sucesso:** validar o fluxo principal descrito nesta SPEC.
- **Validação:** rejeitar dados obrigatórios ausentes ou inválidos.
- **Falha de dependência:** apresentar erro apropriado quando API, banco ou storage não estiver disponível, quando aplicável.
- **Regressão:** garantir que a funcionalidade não viole regras existentes do domínio.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`, quando aplicável.
- Modelo de dados em `docs/modelo-de-dados.md`, quando aplicável.
- Implementações anteriores das quais esta funcionalidade depende.

## 8. Pendências e pontos a confirmar

- O card não define biblioteca de roteamento, gerenciamento de estado, design system ou plataformas-alvo. Registrar essas escolhas como decisão técnica antes de adotá-las.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/gap9zScy
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
