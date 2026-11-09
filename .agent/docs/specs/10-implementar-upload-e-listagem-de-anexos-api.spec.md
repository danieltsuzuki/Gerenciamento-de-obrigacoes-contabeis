# SPEC-010 — Implementar upload e listagem de anexos (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 10 |
| Card | [Implementar upload e listagem de anexos (API)](https://trello.com/c/LU2iFUy2) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Implementar armazenamento de arquivos anexados às obrigações e disponibilizar upload, listagem e download seguro.

## 2. Escopo funcional

- [ ] POST /api/obligations/{id}/attachments recebe multipart/form-data.
- [ ] GET /api/obligations/{id}/attachments lista metadados.
- [ ] GET /api/attachments/{attachmentId}/download retorna arquivo binário.
- [ ] Armazenar arquivo no filesystem local configurável e metadados no MySQL.
- [ ] Gerar chave/nome interno seguro; não confiar no nome original para caminho.
- [ ] Executar compensação removendo arquivo se persistência dos metadados falhar.

## 3. Regras de negócio e restrições

- Obrigação deve existir.
- Arquivo não pode ser vazio.
- Validar nome, MIME/tipo e tamanho máximo.
- Proteger contra path traversal.
- Todas as rotas de anexos exigem JWT.
- MVP mantém arquivo fora do banco e metadados em attachment.

## 4. Contratos e decisões técnicas

- Upload: multipart/form-data com campo `file`.
- Tipos permitidos descritos como PDF, imagens, XML, planilhas e compactados.
- Limite de 10 MB registrado no CHANGELOG.md.
- Storage configurável por `storage.location`.
- Metadados: id, obligationId, name, contentType, size, uploadedAt.

## 5. Critérios de aceitação

- [ ] Upload retorna 201 e metadados.
- [ ] Listagem retorna metadados corretos.
- [ ] Download retorna bytes e Content-Disposition sanitizado.
- [ ] Arquivo acima do limite, MIME inválido, obrigação ausente e falhas de storage são tratados.
- [ ] Testes de storage, serviço, controller e integração aprovados.

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

- A pendência `docs/pendencias-e-perguntas-em-aberto.md` menciona limite e tipos MIME como questão aberta, enquanto CHANGELOG.md registra 10 MB e categorias permitidas. Confirmar a política final e sincronizar os documentos.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/LU2iFUy2
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
