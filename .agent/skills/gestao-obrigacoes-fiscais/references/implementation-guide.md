# Guia de implementação do backend

## Camadas
- Controller: fronteira HTTP; recebe e devolve DTOs, não entidades JPA.
- Service: orquestra casos de uso, valida relações e controla transações.
- Domínio: invariantes e comportamento próprio das entidades/enums.
- Repository: consultas e persistência estritamente necessárias; sem operações `delete*`.
- Storage: abstração para gravar/ler binários fora do banco.

Inspecione os pacotes reais antes de criar estrutura. O exemplo abaixo é conceitual, não uma exigência de nomes:
`company/`, `responsible/`, `obligation/`, `attachment/`, `auth/`, `shared/`.

## Validação e unicidade
- Normalize CNPJ antes de validar e consultar duplicidade; persista somente os 14 dígitos.
- Normalize e-mail com trim + lowercase antes de validar e consultar duplicidade.
- Use constraints UNIQUE no MySQL como garantia final contra concorrência; trate violações para resposta coerente.
- Não use regex isolada como substituto de validação de dígitos verificadores do CNPJ.

## Elegibilidade
- Na criação de obrigação, empresa e responsável precisam existir e estar ativos.
- Na edição, revalide somente o vínculo que mudou.
- A inativação altera `active`, preservando obrigações anteriores.

## API e segurança
- Contratos completos estão em `docs/api.md`; respeite prefixo `/api`, nomes, payloads, paginação e erros.
- Controllers devem manter DTOs de request/response.
- JWT Bearer: `POST /api/auth/register` e `POST /api/auth/login` são públicos; GETs documentados são anônimos; mutações e operações de anexos exigem autenticação.
- Senhas são armazenadas com BCrypt conforme o changelog/status documentado e nunca retornadas.
- Não invente RBAC, autorização por papel ou autorização exclusiva do responsável.

## Anexos
- Interface de storage separa filesystem da lógica de negócio.
- Diretório de armazenamento é configurável.
- Caminho/chave é gerado pelo servidor, com identificador único; nome original fica em `file_name`.
- Evite path traversal; sanitize `Content-Disposition` no download.
- Grave o arquivo e depois os metadados; se persistência falhar, remova o arquivo gravado.
- A API documenta tipos MIME de PDF, imagens, XML, planilhas e compactados. O changelog registra máximo de 10 MB. Confirme implementação/configuração atuais antes de mudar qualquer limite ou allowlist.

## Tratamento de erros
Use os códigos/status já definidos em `docs/api.md`. Não introduza formato alternativo de erro sem atualizar contrato, tratamento global, testes e documentação.

## Testes
- Unitários: normalização/validação CNPJ e e-mail; regras de status.
- Serviços: inativos, duplicidades e edição sem alteração de vínculo.
- Integração: migrations, constraints, FKs, autenticação e fluxos HTTP.
- Storage: nome malicioso, falha de I/O, compensação e download.
- Use Testcontainers MySQL 8 onde o projeto já utiliza esse padrão. Confirme disponibilidade de Docker no ambiente.
