# SPEC-041 — Resolução das Pendências de Domínio (Imutabilidade de Concluídas, Autorização por Responsável, Status Atrasada, CNPJ Alfanumérico e Recorrência)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar: "Resolução de Pendências de Negócio e Domínio") |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Aprovada em discussão técnica (10/11/2026) |
| Tipo | Regras de Negócio e Domínio (Backend e Frontend) |

## 1. Objetivo

Implementar e validar as definições de regras de negócio acordadas para as 5 questões em aberto do sistema, eliminando ambiguidades e blindando a integridade do domínio fiscal:
1. **Imutabilidade de Anexos em Obrigações Concluídas:** tornar o histórico de obrigações `COMPLETED` 100% imutável contra novos uploads.
2. **Autorização por Responsável no Ciclo de Vida:** garantir que apenas o responsável atribuído à obrigação possua permissão para avançar o seu status.
3. **Decisão Formal de Recorrência:** consolidar arquiteturalmente que não haverá recorrência automática no MVP, mantendo as obrigações como avulsas.
4. **Status Derivado "Atrasada":** destacar visualmente na interface obrigações com prazo vencido (`dueDate < hoje` e `status != COMPLETED`) sem alterar o enum do banco de dados.
5. **CNPJ Alfanumérico da Receita Federal:** suportar tanto o formato clássico numérico (14 dígitos) quanto o novo formato alfanumérico da Receita Federal nas validações de backend e frontend.

---

## 2. Escopo Funcional e Detalhamento Técnico

### 2.1. Imutabilidade de Anexos em Obrigações Concluídas
- **Backend:**
  - No `AttachmentService` (ou `ObligationService`), ao receber requisição para `POST /api/obligations/{id}/attachments`, validar se `obligation.getStatus() == ObligationStatus.COMPLETED`.
  - Se estiver `COMPLETED`, rejeitar o upload lançando exceção de regra de negócio mapeada para `422 Unprocessable Entity` (com código `OBLIGATION_COMPLETED` e mensagem amigável: *"Não é permitido adicionar novos anexos a uma obrigação já concluída"*).
  - O download de anexos (`GET /api/attachments/{id}/download`) e a listagem de anexos permanecem liberados para consulta de auditoria e histórico fiscal.
- **Frontend:**
  - Na tela `ObligationDetailPage`:
    - Se a obrigação estiver com status `COMPLETED`, o botão "Anexar Arquivo" deve ficar desabilitado ou oculto.
    - Se desabilitado, exibir tooltip/aviso contextual informando que obrigações concluídas são imutáveis.

### 2.2. Autorização por Responsável no Avanço de Status
- **Backend:**
  - Em `PATCH /api/obligations/{id}/status` e no `PUT /api/obligations/{id}` (quando houver tentativa de transição de status):
    - Extrair a identidade do usuário autenticado no token JWT via `SecurityContextHolder`.
    - Comparar o responsável logado com o `obligation.getResponsible()`.
    - Se o usuário autenticado não for o responsável atribuído à obrigação, recusar a operação com status HTTP `403 Forbidden` (código `FORBIDDEN` ou `UNAUTHORIZED_STATUS_CHANGE`, mensagem: *"Apenas o usuário responsável atribuído pode avançar o status desta obrigação"*).
- **Frontend:**
  - Na tela `ObligationDetailPage`:
    - Comparar o usuário logado (`authSessionController.currentUser`) com `obligation.responsible`.
    - Caso o usuário não seja o responsável atribuído:
      - Ocultar ou desabilitar os botões de ação ("Iniciar Execução" e "Concluir Obrigação").
      - Exibir aviso sutil: *"Apenas o responsável (<nome>) pode alterar o status desta obrigação"*.

### 2.3. Recorrência de Obrigações (Definição de Escopo do MVP)
- Registrar na arquitetura e documentação de domínio que, no escopo deste MVP, não existirá geração de obrigações recorrentes (mensais/anuais automáticas).
- Todas as obrigações são cadastradas de forma avulsa. A estrutura do banco e endpoints atuais atende 100% ao requisito sem acréscimo de complexidade desnecessária.

### 2.4. Status Derivado "Atrasada" no Frontend
- **Backend:**
  - Manter o enum `ObligationStatus` com os 3 valores originais: `PENDING`, `IN_PROGRESS`, `COMPLETED`.
  - O banco de dados preserva a constraint de integridade `CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED'))`.
- **Frontend:**
  - Utilizar a propriedade computada `obligation.isOverdue` (`dueDate.isBefore(hoje) && status != ObligationStatus.completed`).
  - Em `ObligationListPage` (cards e tabela) e `ObligationDetailPage`:
    - Exibir um badge/chip de alerta visual evidente (cor vermelha/laranja de alerta com ícone de aviso) com o texto **"Atrasada"** ao lado do status original (ex.: `Pendente (Atrasada)` ou chip dedicado de alerta).
    - Permitir identificação visual instantânea para a equipe contábil.

### 2.5. Suporte a CNPJ Alfanumérico da Receita Federal
- **Regra da RFB:**
  - Comprimento: 14 posições (ou 18 com formatação: `XX.XXX.XXX/XXXX-XX`).
  - As primeiras 12 posições (8 da raiz + 4 de filial/ordem) aceitam caracteres alfanuméricos (`0-9` e `A-Z` em maiúsculas).
  - As últimas 2 posições são os dígitos verificadores (DVs), calculados por algoritmo ponderado módulo 11 utilizando os valores ASCII dos caracteres base subtraídos de 48 (o que é matematicamente equivalente e retrocompatível com o CNPJ numérico clássico).
- **Backend:**
  - Atualizar o validador `Cnpj.java` e a anotação `@ValidCnpj`:
    - Normalizar removendo formatação (`.`, `/`, `-`) e convertendo para maiúsculo (`toUpperCase()`).
    - Validar comprimento exato de 14 caracteres alfanuméricos (`^[0-9A-Z]{12}[0-9]{2}$`).
    - Implementar a rotina de cálculo dos dois dígitos verificadores com pesos [5,4,3,2,9,8,7,6,5,4,3,2] e [6,5,4,3,2,9,8,7,6,5,4,3,2], utilizando `char - 48` para cada caractere.
    - Manter rejeição a sequências idênticas inválidas.
  - Banco de Dados: a coluna `cnpj VARCHAR(14)` na tabela `company` já suporta texto alfanumérico sem necessidade de alteração de DDL.
- **Frontend:**
  - Atualizar `CnpjValidator` no Flutter:
    - Aceitar letras e números no regex de validação e na máscara.
    - Manter validação instantânea inline no formulário `CompanyFormPage`.

---

## 3. Critérios de Aceitação

- [ ] **Imutabilidade:** `POST /api/obligations/{id}/attachments` em obrigação com status `COMPLETED` retorna `422 Unprocessable Entity` com código de erro amigável.
- [ ] **UI Imutabilidade:** Botão de upload em `ObligationDetailPage` bloqueado/oculto para obrigações concluídas.
- [ ] **Autorização:** Usuário autenticado que não seja o responsável da obrigação recebe `403 Forbidden` ao tentar mudar status via `PATCH /api/obligations/{id}/status` ou `PUT`.
- [ ] **UI Autorização:** Botões de transição de status habilitados exclusivamente quando o usuário logado for o responsável pela obrigação.
- [ ] **Status Atrasada:** Obrigações com data de vencimento anterior à data atual e não concluídas exibem indicador visual destacado de "Atrasada" na listagem e na tela de detalhes.
- [ ] **CNPJ Alfanumérico:**
  - CNPJs válidos no padrão clássico numérico continuam sendo aceitos (ex.: `33.000.167/0001-01`).
  - CNPJs válidos no novo padrão alfanumérico da RFB são aceitos e normalizados com sucesso.
  - CNPJs com DVs incorretos (sejam numéricos ou alfanuméricos) são rejeitados com `400 VALIDATION_ERROR`.
- [ ] **Testes:**
  - Testes unitários e de integração cobrindo cada nova regra no backend.
  - Testes de widget e models cobrindo as atualizações no frontend.
- [ ] **Documentação:**
  - `docs/pendencias-e-perguntas-em-aberto.md` atualizado com as decisões.
  - `docs/api.md` atualizado refletindo o retorno `403` no PATCH de status e `422` no upload de obrigação concluída.

---

## 4. Cenários de Teste

1. **Cenário 1 — Upload em Obrigação Concluída:**
   - Criar obrigação e avançá-la para `COMPLETED`.
   - Tentar enviar anexo via `POST /api/obligations/{id}/attachments`.
   - Esperado: HTTP 422 (`OBLIGATION_COMPLETED`).
2. **Cenário 2 — Mudança de Status por Outro Usuário:**
   - Obrigação atribuída ao responsável com email `resp1@teste.com`.
   - Fazer login com usuário `resp2@teste.com`.
   - Tentar avançar o status da obrigação via `PATCH /api/obligations/{id}/status`.
   - Esperado: HTTP 403 (`FORBIDDEN`).
3. **Cenário 3 — Mudança de Status pelo Responsável Atribuído:**
   - Fazer login com `resp1@teste.com`.
   - Avançar status `PENDING -> IN_PROGRESS`.
   - Esperado: HTTP 200 e status atualizado com sucesso.
4. **Cenário 4 — Destaque Visual de Atrasada:**
   - Obrigação com `dueDate = ontem` e status `PENDING`.
   - Renderizar tela de listagem e detalhes no Flutter.
   - Esperado: Indicador/badge "Atrasada" presente na tela.
5. **Cenário 5 — CNPJ Alfanumérico e Numérico:**
   - Testar cadastro de empresa com CNPJ numérico válido: sucesso.
   - Testar cadastro de empresa com CNPJ alfanumérico válido: sucesso.
   - Testar com dígitos verificadores inválidos: erro de validação (400).

---

## 5. Rastreabilidade
- `docs/pendencias-e-perguntas-em-aberto.md`
- `docs/api.md`
- `docs/modelo-de-dados.md`
- `docs/status-implementacao.md`

