# SPEC-007 — Implementar cadastro e consulta de responsáveis (API)

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | 7 |
| Card | [Implementar cadastro e consulta de responsáveis (API)](https://trello.com/c/Lq9Oed4J) |
| Status no Trello (09/11/2026) | Concluído |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft — derivada do card e da documentação disponível |

## 1. Objetivo

Disponibilizar API para cadastro, consulta, listagem e atualização de responsáveis. O estado atual também inclui autenticação JWT registrada no histórico do card e em docs/api.md.

## 2. Escopo funcional

- [ ] POST /api/responsibles cadastra responsável.
- [ ] GET /api/responsibles lista com paginação e filtro active opcional.
- [ ] GET /api/responsibles/{id} consulta responsável sem expor senha/hash.
- [ ] PUT /api/responsibles/{id} atualiza nome, e-mail e active.
- [ ] POST /api/auth/register registra usuário.
- [ ] POST /api/auth/login autentica e emite JWT.

## 3. Regras de negócio e restrições

- E-mail é obrigatório, validado e único.
- Senha nunca é retornada em DTO de resposta; persistir hash BCrypt.
- Usuários inativos não podem autenticar.
- GET de consulta é anônimo; mutações protegidas por JWT, exceto register/login.
- Inativação lógica por active=false; sem DELETE físico.

## 4. Contratos e decisões técnicas

- POST /api/responsibles: name, email, password, active (senha 6–100 caracteres conforme docs/api.md).
- GET list: active opcional, page=0, size=20, sort=id,asc.
- PUT: name, email, active.
- POST /api/auth/register e POST /api/auth/login.
- JWT Bearer; expiração padrão 30 minutos (1800s).

## 5. Critérios de aceitação

- [ ] CRUD de responsáveis e autenticação funcionam conforme contrato.
- [ ] E-mail duplicado retorna 409 DUPLICATE_EMAIL.
- [ ] Credenciais inválidas/inativo retornam 401.
- [ ] Resposta não contém password/hash.
- [ ] Testes unitários, WebMvc e integração MySQL cobrem fluxos.

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

- O card original não detalha autenticação; a inclusão foi baseada no histórico do card e nos docs/api.md/CHANGELOG.md. Confirmar se o cadastro público (register) permanecerá habilitado no produto.

## 9. Rastreabilidade

- Card Trello: https://trello.com/c/Lq9Oed4J
- Documentação de referência: `docs/index.md`, `docs/api.md`, `docs/modelo-de-dados.md`, `docs/status-implementacao.md`, `docs/pendencias-e-perguntas-em-aberto.md`, `docs/CHANGELOG.md` e ADRs, conforme aplicável.
