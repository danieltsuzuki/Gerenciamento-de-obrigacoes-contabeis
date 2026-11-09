# SPEC-022 — Implementar download/abertura de anexos

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 22 |
| Card | [Implementar download/abertura de anexos](https://trello.com/c/MjvDJYIU) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Permitir baixar ou abrir arquivos já anexados a uma obrigação.

## 2. Escopo funcional

- [ ] Disponibilizar ação para baixar/abrir anexo.
- [ ] Consumir endpoint de download.
- [ ] Tratar progresso quando suportado pela implementação escolhida.
- [ ] Tratar indisponibilidade e erros sem bloquear a tela.
- [ ] Garantir que o arquivo recebido corresponda ao anexo selecionado.

## 3. Regras de negócio e restrições

- Download exige JWT.
- Não confiar apenas no nome exibido; usar identificador do anexo.
- Falhas de rede/arquivo inexistente devem ser comunicadas.
- A tela permanece utilizável durante a operação.

## 4. Contratos e decisões técnicas

- GET /api/attachments/{attachmentId}/download.
- Resposta binária com Content-Type e Content-Disposition sanitizado.
- Erros documentados: 401, 404, 500 STORAGE_ERROR.

## 5. Critérios de aceitação

- [ ] Arquivo baixado/aberto corresponde ao registro selecionado.
- [ ] Falha de download não trava tela.
- [ ] Feedback de progresso/erro é apresentado quando aplicável.

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

- O card não especifica diretório local, política de cache, nome final, suporte offline nem visualizador embutido. Definir conforme plataformas Flutter suportadas.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/MjvDJYIU
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
