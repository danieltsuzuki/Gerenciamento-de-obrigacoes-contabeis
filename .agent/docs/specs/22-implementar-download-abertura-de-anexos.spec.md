# SPEC-022 — Implementar download/abertura de anexos

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 22 |
| Card | [Implementar download/abertura de anexos](https://trello.com/c/MjvDJYIU) |
| Status no Trello (10/11/2026) | Concluído |
| Versão da SPEC | 1.1 |
| Situação da especificação | Concluída e testada |

## 1. Objetivo

Permitir baixar ou abrir arquivos já anexados a uma obrigação.

## 2. Escopo funcional

- [x] Disponibilizar ação para baixar/abrir anexo.
- [x] Consumir endpoint de download (`GET /api/attachments/{attachmentId}/download`).
- [x] Tratar progresso quando suportado pela implementação escolhida.
- [x] Tratar indisponibilidade e erros sem bloquear a tela.
- [x] Garantir que o arquivo recebido corresponda ao anexo selecionado.

## 3. Regras de negócio e restrições

- Download exige JWT.
- Não confiar apenas no nome exibido; usar identificador numérico do anexo (`attachment.id`).
- Falhas de rede/arquivo inexistente (`404 NOT_FOUND`, `500 STORAGE_ERROR`) são comunicadas via SnackBar sem travar a interface.
- A tela permanece totalmente utilizável durante a operação.

## 4. Contratos e decisões técnicas

- GET /api/attachments/{attachmentId}/download.
- Resposta binária com Content-Type e Content-Disposition sanitizado via `DownloadedFile`.
- Salvamento local via `FileSaverService` (`platform_file_saver_io.dart` na pasta Downloads do desktop e `platform_file_saver_web.dart` via Blob e âncora de download no navegador).
- Erros documentados: 401, 404, 500 STORAGE_ERROR.

## 5. Critérios de aceitação

- [x] Arquivo baixado/aberto corresponde ao registro selecionado.
- [x] Falha de download não trava tela.
- [x] Feedback de progresso/erro é apresentado de forma clara.

## 6. Cenários de teste

- **Sucesso:** validar download de anexo por ID, salvamento local e SnackBar de sucesso.
- **Progresso:** exibir spinner dedicado no item em download e evitar cliques concorrentes duplicados.
- **Tratamento de Erros:** tratar 404 (anexo inexistente), 401 (não autenticado), 500 (erro de storage) e falha de conexão.
- **Regressão:** garantir que a interface continue responsiva e que os 142 testes do frontend passem.

## 7. Dependências

- Especificações de arquitetura e domínio do projeto.
- Contratos REST documentados em `docs/api.md`.
- Camada de autenticação JWT e `AttachmentRepository.downloadAttachment`.

## 8. Pendências e pontos a confirmar

- Nenhuma pendência em aberto.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/MjvDJYIU
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/CHANGELOG.md`.
