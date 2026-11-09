# SPEC-013 — Criar estrutura e navegação do Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 13 |
| Card | [Criar estrutura e navegação do Flutter](https://trello.com/c/gap9zScy) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Criar o aplicativo Flutter, sua estrutura por features e a navegação entre telas principais.

## 2. Escopo funcional

- [ ] Criar projeto Flutter e configurar ambientes.
- [ ] Organizar features companies, responsibles e obligations.
- [ ] Separar camadas data/domain/presentation.
- [ ] Configurar roteamento, tema e componentes compartilhados.
- [ ] Definir estados de loading, erro e vazio reutilizáveis.
- [ ] Configurar cliente HTTP e base URL por ambiente.

## 3. Regras de negócio e restrições

- A interface não deve concentrar chamadas HTTP diretamente nos widgets.
- URL da API deve ser configurável por ambiente.
- Estados de loading/erro/vazio devem ter tratamento consistente.

## 4. Contratos e decisões técnicas

- Flutter; organização por features; camadas data/domain/presentation.
- Features iniciais: companies, responsibles, obligations.
- Cliente HTTP configurado para backend Spring Boot.

## 5. Critérios de aceitação

- [ ] App inicia sem erros.
- [ ] Navegação entre telas principais funciona.
- [ ] Tema e componentes compartilhados estão configurados.
- [ ] Base URL não está hardcoded em widgets.

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
