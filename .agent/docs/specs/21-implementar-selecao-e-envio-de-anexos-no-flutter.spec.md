# SPEC-021 — Implementar seleção e envio de anexos no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 21 |
| Card | [Implementar seleção e envio de anexos no Flutter](https://trello.com/c/CauV2GQ2) |
| Status no Trello (09/11/2026) | A Fazer |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Permitir selecionar arquivo local e enviá-lo para uma obrigação, atualizando os metadados apresentados.

## 2. Escopo funcional

- [ ] Permitir seleção de arquivo.
- [ ] Enviar arquivo para a obrigação selecionada.
- [ ] Atualizar lista e contador após sucesso.
- [ ] Exibir nome, tipo, tamanho e data de envio.
- [ ] Tratar permissões, cancelamento, limite de tamanho e falhas de rede.
- [ ] Exibir feedback claro.

## 3. Regras de negócio e restrições

- Arquivo deve estar associado à obrigação correta.
- Não enviar arquivo vazio ou maior que limite aceito.
- API valida MIME/tipo e tamanho; cliente deve orientar o usuário, sem substituir validação do servidor.
- Upload exige JWT.

## 4. Contratos e decisões técnicas

- POST /api/obligations/{id}/attachments multipart/form-data campo file.
- GET /api/obligations/{id}/attachments para atualizar metadados.
- Limite de 10 MB consta no CHANGELOG.md; MIME permitidos descritos na documentação de anexos.

## 5. Critérios de aceitação

- [ ] Usuário seleciona e envia arquivo.
- [ ] Sucesso atualiza lista e contador.
- [ ] Cancelamento/permissão/rede/validação apresentam feedback.
- [ ] Metadados exibidos correspondem à resposta da API.

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

- Confirmar limite e allowlist MIME final: docs/pendencias-e-perguntas-em-aberto.md ainda lista essa política como questão aberta, apesar do changelog registrar 10 MB.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/CauV2GQ2
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
