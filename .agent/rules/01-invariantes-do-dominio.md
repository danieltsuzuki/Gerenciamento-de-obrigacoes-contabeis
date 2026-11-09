# Invariantes do domínio

Aplicável a qualquer alteração que envolva `Company`, `Responsible`, `Obligation` ou `Attachment`.

## Relacionamentos e persistência
- `Company` 1:N `Obligation`.
- `Responsible` 1:N `Obligation`; a entidade Java `Responsible` é persistida na tabela `users`.
- `Obligation` 1:N `Attachment`.
- Toda obrigação possui uma empresa e um responsável (`NOT NULL`); todo anexo pertence a uma obrigação existente.
- Preserve FKs e constraints no banco. A validação JPA/serviço não substitui a integridade referencial do MySQL.

## Histórico: sem exclusão física
- Não exponha operações de exclusão física para empresas, responsáveis/usuários, obrigações ou anexos.
- Empresas e responsáveis são inativados por `active`; inativar não remove nem altera obrigações históricas.
- Não adicione métodos `delete*` aos repositories. A decisão aceita ADR-0001 determina que repositories estendam `Repository` e declarem apenas operações de leitura, gravação e consulta necessárias.
- FKs não devem usar `ON DELETE CASCADE`; não configure cascata de remoção nem `orphanRemoval`.
- Não implemente exclusão física administrativa sem ADR/decisão explícita.

## Identificadores únicos
- CNPJ: normalize removendo formatação, valide os dígitos verificadores e persista somente os 14 dígitos. A constraint `uk_company_cnpj` é a garantia final de unicidade.
- E-mail: remova espaços externos, converta para minúsculas e valide o formato antes de consultar duplicidade/persistir. A constraint `uk_users_email` é a garantia final.
- Faça tratamento amigável de colisões de unicidade, inclusive `DataIntegrityViolationException` quando aplicável.
- O modelo documentado atualmente é CNPJ numérico de 14 dígitos. CNPJ alfanumérico não está definido como comportamento implementado; não o adicione sem decisão e atualização documental.

## Elegibilidade
- Uma empresa ou responsável inativo não pode receber uma nova atribuição.
- Na criação da obrigação, valide empresa e responsável ativos.
- Na edição, valide o novo vínculo somente quando `companyId` ou `responsibleId` realmente mudar. Uma edição de título/prazo não deve falhar apenas porque o vínculo histórico tornou-se inativo.
- Inativar empresa/responsável não deve alterar vínculos já existentes.

## Senhas e autenticação
- Nunca armazene senha em texto puro. A documentação atual descreve BCrypt.
- Nunca exponha hash/senha em DTOs ou respostas.
- Endpoints de mutação e anexos seguem a política JWT documentada em `docs/api.md`; login e registro são públicos. GETs da API são anônimos conforme a política de segurança documentada.
- Não invente perfis, permissões por papel, refresh token ou autorização por responsável: esses comportamentos não estão especificados.

## Ciclo de vida
- Toda obrigação nasce `PENDING`.
- Transições válidas: `PENDING → IN_PROGRESS` e `IN_PROGRESS → COMPLETED`.
- `COMPLETED` é terminal. Não permita saltos, regressões ou transição para o mesmo status.
- Ao concluir, preencha `completedAt`/`completed_at`; tentativas rejeitadas não podem alterar status nem data de conclusão.
- Valide a transição no domínio/serviço. A constraint `CHECK` do banco limita os valores possíveis, mas não substitui a máquina de estados.
- A API documenta tanto `PATCH /api/obligations/{id}/status` quanto alteração opcional de status no `PUT /api/obligations/{id}`. Preserve o contrato existente; não remova nem amplie essa possibilidade sem decisão coordenada e atualização dos testes/docs.

## Anexos
- Armazene o binário no filesystem local configurável; persista no MySQL somente metadados e chave/caminho seguro.
- Gere o caminho no servidor com identificador único; nunca use o nome enviado pelo cliente como caminho.
- Proteja contra path traversal e sanitize o nome apresentado no download.
- Se o registro dos metadados falhar após gravar o arquivo, execute compensação removendo o arquivo recém-gravado.
- A documentação de API lista PDF, imagens, XML, planilhas e compactados. O changelog registra limite de 10 MB. Há divergência com a lista de pendências, que ainda diz que limite/tipos precisam ser confirmados: antes de alterar esses limites, confira configuração e implementação reais.
- Não presuma política de remoção/substituição de anexos em obrigação concluída; permanece pendente.
