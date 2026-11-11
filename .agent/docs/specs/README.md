# Specs — Gerenciador de Obrigações Contábeis

Este diretório contém uma especificação por card do quadro Trello **Gerenciador de Obrigações Contábeis**.

## Fontes utilizadas

1. Cards e descrições do quadro Trello, incluindo os critérios de aceite.
2. `docs.rar`, com `api.md`, `modelo-de-dados.md`, `status-implementacao.md`, `pendencias-e-perguntas-em-aberto.md`, `CHANGELOG.md`, `index.md` e `decisoes/ADR-0001-repositories-sem-operacoes-de-exclusao.md`.
3. Histórico visível dos cards quando disponível.

As SPECs preservam as decisões das fontes. Pontos não definidos ou contraditórios foram marcados como pendências, em vez de tratados como requisitos confirmados.

## Tecnologias e contexto

- Backend: Java 21, Spring Boot, MySQL, Flyway, Spring Data JPA, Bean Validation.
- Frontend: Flutter.
- API: REST/JSON.
- Autenticação documentada: JWT Bearer.
- Anexos: filesystem local configurável; metadados no MySQL.

## Índice e status no Trello em 09/11/2026

| SPEC | Card | Status |
|---|---|---|
| [SPEC-001](./01-definir-arquitetura-escopo-do-mvp-e-convencoes.spec.md) | [Definir arquitetura, escopo do MVP e convenções](https://trello.com/c/tFmtVqaG) | Concluído |
| [SPEC-002](./02-modelar-dominio-e-relacionamentos.spec.md) | [Modelar domínio e relacionamentos](https://trello.com/c/JC3uAD5L) | Concluído |
| [SPEC-003](./03-criar-repositorio-e-estrutura-do-backend.spec.md) | [Criar repositório e estrutura do backend](https://trello.com/c/WvGyaN2y) | Concluído |
| [SPEC-004](./04-configurar-mysql-e-migrations-com-flyway.spec.md) | [Configurar MySQL e migrations com Flyway](https://trello.com/c/9jS8YJYi) | Concluído |
| [SPEC-005](./05-implementar-entidades-e-mapeamentos-jpa.spec.md) | [Implementar entidades e mapeamentos JPA](https://trello.com/c/cyN0GakG) | Concluído |
| [SPEC-006](./06-implementar-cadastro-e-consulta-de-empresas-api.spec.md) | [Implementar cadastro e consulta de empresas (API)](https://trello.com/c/sdG0b0yu) | Concluído |
| [SPEC-007](./07-implementar-cadastro-e-consulta-de-responsaveis-api.spec.md) | [Implementar cadastro e consulta de responsáveis (API)](https://trello.com/c/Lq9Oed4J) | Concluído |
| [SPEC-008](./08-implementar-cadastro-e-consulta-de-obrigacoes-api.spec.md) | [Implementar cadastro e consulta de obrigações (API)](https://trello.com/c/qso1Id1r) | Concluído |
| [SPEC-009](./09-implementar-maquina-de-estados-da-obrigacao.spec.md) | [Implementar máquina de estados da obrigação](https://trello.com/c/YDrtyWN1) | Concluído |
| [SPEC-010](./10-implementar-upload-e-listagem-de-anexos-api.spec.md) | [Implementar upload e listagem de anexos (API)](https://trello.com/c/LU2iFUy2) | Concluído |
| [SPEC-011](./11-padronizar-dtos-validacoes-e-tratamento-de-excecoes.spec.md) | [Padronizar DTOs, validações e tratamento de exceções](https://trello.com/c/OARCmyxB) | Concluído |
| [SPEC-012](./12-adicionar-testes-do-backend.spec.md) | [Adicionar testes do backend](https://trello.com/c/Ai2NCneJ) | Concluído |
| [SPEC-013](./13-criar-estrutura-e-navegacao-do-flutter.spec.md) | [Criar estrutura e navegação do Flutter](https://trello.com/c/gap9zScy) | Concluído |
| [SPEC-014](./14-implementar-camada-de-integracao-com-api.spec.md) | [Implementar camada de integração com API](https://trello.com/c/V7l7sJPV) | Concluído |
| [SPEC-015](./15-criar-tela-de-listagem-de-obrigacoes.spec.md) | [Criar tela de listagem de obrigações](https://trello.com/c/3wpXjbhp) | Concluído |
| [SPEC-016](./16-criar-listagem-e-formulario-de-empresas.spec.md) | [Criar listagem e formulário de empresas](https://trello.com/c/qiztV9zZ) | Concluído |
| [SPEC-017](./17-criar-listagem-e-formulario-de-responsaveis.spec.md) | [Criar listagem e formulário de responsáveis](https://trello.com/c/ru5UKQDg) | A Fazer |
| [SPEC-018](./18-criar-formulario-de-cadastro-e-edicao-de-obrigacoes.spec.md) | [Criar formulário de cadastro e edição de obrigações](https://trello.com/c/DlkBtqch) | A Fazer |
| [SPEC-019](./19-criar-tela-de-detalhes-da-obrigacao.spec.md) | [Criar tela de detalhes da obrigação](https://trello.com/c/82pKQj1o) | A Fazer |
| [SPEC-020](./20-implementar-fluxo-de-alteracao-de-status-no-flutter.spec.md) | [Implementar fluxo de alteração de status no Flutter](https://trello.com/c/gChKmU1v) | A Fazer |
| [SPEC-021](./21-implementar-selecao-e-envio-de-anexos-no-flutter.spec.md) | [Implementar seleção e envio de anexos no Flutter](https://trello.com/c/CauV2GQ2) | A Fazer |
| [SPEC-022](./22-implementar-download-abertura-de-anexos.spec.md) | [Implementar download/abertura de anexos](https://trello.com/c/MjvDJYIU) | A Fazer |
| [SPEC-023](./23-adicionar-testes-do-flutter.spec.md) | [Adicionar testes do Flutter](https://trello.com/c/JN4XYhU1) | A Fazer |
| [SPEC-024](./24-documentar-execucao-arquitetura-e-api.spec.md) | [Documentar execução, arquitetura e API](https://trello.com/c/c3Ti7JGA) | A Fazer |
| [SPEC-025](./25-preparar-entrega-revisao-e-pull-request.spec.md) | [Preparar entrega, revisão e Pull Request](https://trello.com/c/dK9X0JMO) | Backlog |
| [SPEC-026](./26-implementar-autenticacao-no-flutter.spec.md) | Implementar autenticação e tela de login no Flutter (sem card; unificada com a interface de login) | Concluído |

> Os status das SPEC-017 a SPEC-025 acima refletem o Trello em 09/11/2026. Na implementação, todas estão concluídas e testadas (ver `docs/status-implementacao.md`); o quadro deve ser sincronizado (SPEC-028).

## SPECs derivadas da validação de conformidade com o enunciado (10/11/2026)

| SPEC | Tema | Tipo | Status |
|---|---|---|---|
| [SPEC-027](./27-consolidar-diferenciais-implementados.spec.md) | Diferenciais já implementados: Autenticação, OpenAPI/Swagger, Upload físico | Diferencial | Concluído (retroativa) |
| [SPEC-028](./28-completar-readme-e-artefatos-de-entrega.spec.md) | Completar README (decisões arquiteturais, melhorias futuras) e links de entrega | Obrigatório | Backlog |
| [SPEC-029](./29-corrigir-inconsistencias-de-contrato-e-seguranca.spec.md) | Corrigir inconsistências de contrato (status no PUT, `dueFrom`/`dueTo`) e segredo JWT padrão | Obrigatório | Backlog |
| [SPEC-030](./30-containerizar-backend-e-frontend-com-docker.spec.md) | Docker | Diferencial | Backlog |
| [SPEC-031](./31-orquestrar-stack-com-docker-compose.spec.md) | Docker Compose | Diferencial | Backlog |
| [SPEC-032](./32-implementar-paginacao-no-flutter.spec.md) | Paginação (frontend) | Diferencial | Backlog |
| [SPEC-033](./33-implementar-pesquisa-textual.spec.md) | Pesquisa | Diferencial | Backlog |
| [SPEC-034](./34-implementar-filtros-avancados-no-flutter.spec.md) | Filtros | Diferencial | Backlog |
| [SPEC-035](./35-implementar-auditoria-e-historico-de-status.spec.md) | Auditoria | Diferencial | Backlog |
| [SPEC-036](./36-implementar-logs-estruturados.spec.md) | Logs | Diferencial | Backlog |
| [SPEC-037](./37-implementar-cache-de-consultas.spec.md) | Cache | Diferencial | Backlog |
| [SPEC-038](./38-implementar-tema-claro-e-escuro.spec.md) | Tema claro e escuro | Diferencial | Backlog |
| [SPEC-039](./39-configurar-pipeline-ci-cd.spec.md) | CI/CD | Diferencial | Backlog |
| [SPEC-040](./40-medir-e-garantir-cobertura-de-testes.spec.md) | Cobertura de testes | Diferencial | Backlog |
| [SPEC-041](./41-regras-negocio-pendencias-e-perguntas-em-aberto.spec.md) | Resolução de Pendências de Domínio (Imutabilidade de Concluídas, Autorização por Responsável, Status Atrasada, CNPJ Alfanumérico e Recorrência) | Regras de Negócio | Backlog |

## Observações de consistência

- `Responsible` é a entidade de domínio; a tabela física correspondente é `users`.
- A API documenta `PATCH /api/obligations/{id}/status` como operação explícita de transição. Também há suporte documentado a `status` opcional no `PUT /api/obligations/{id}`; a UI deve preferir o PATCH dedicado.
- O fluxo de autenticação JWT aparece nos documentos do backend e no histórico do card de responsáveis, embora não exista card exclusivo de autenticação.
- O changelog registra limite de anexo de 10 MB e allowlist de tipos; o documento de pendências ainda pede confirmação desses parâmetros.
- A documentação registra testes com Testcontainers MySQL 8, JaCoCo e Swagger/OpenAPI.
- Não foi inventada biblioteca de estado/roteamento Flutter, política de refresh JWT, autorização por perfil, recorrência de obrigações ou regra de anexos após conclusão.

## Convenção

Cada arquivo contém objetivo, escopo, regras, contratos/decisões técnicas, critérios de aceitação, cenários de teste, dependências, pendências e rastreabilidade.
