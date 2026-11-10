# Desenvolvimento Frontend Baseado Exclusivamente em Documentação

Ao realizar qualquer tarefa no frontend Flutter (análise, implementação, refatoração, testes ou revisão dentro de `frontend/` ou SPECs 13 a 23):

## 1. Proibição de Leitura de Código do Backend
- O assistente **NÃO DEVE inspecionar, pesquisar ou ler arquivos de código-fonte do backend** (`backend/src/**`, classes Java, controllers, services, repositories, entidades, migrations, etc.).
- O desenvolvimento do frontend deve ocorrer como se o backend fosse um serviço externo consumido estritamente via contrato publicado.

## 2. Documentação Técnica como Fonte Única da Verdade
Todos os requisitos, endpoints, payloads, formatos de dados, regras de negócio e fluxos do frontend devem ser consultados exclusivamente em:
- **`docs/api.md`:** Contratos REST oficiais, rotas (`/api/**`), métodos HTTP, payloads de envio (JSON/multipart), respostas de sucesso, paginação, filtros de busca (`dueFrom`, `dueTo`, `status`, etc.) e códigos de erro (`VALIDATION_ERROR`, `NOT_FOUND`, `DUPLICATE_*`, `INVALID_STATUS_TRANSITION`, `COMPANY_INACTIVE`, `USER_INACTIVE`, etc.).
- **`docs/arquitetura.md`:** Arquitetura oficial do frontend (*Feature-First* + *Clean Architecture*: `data`, `domain`, `presentation`), diretrizes de interceptor JWT e armazenamento seguro de tokens.
- **`docs/modelo-de-dados.md`:** Modelo relacional e regras de atributos do domínio (ex.: normalização de CNPJ, obrigatoriedade de campos).
- **`.agent/docs/specs/`:** Especificações funcionais dos cards do Flutter (SPECs 13 a 23).
- **`docs/status-implementacao.md`:** Regras de negócio confirmadas (RN-001 a RN-009).

## 3. Comportamento em Caso de Dúvidas ou Lacunas
- Se houver divergência, omissão ou ambiguidade na documentação, **NÃO abra os arquivos do backend para "descobrir" o comportamento**.
- Aponte a lacuna explicitamente para o usuário, consulte as pendências em `docs/pendencias-e-perguntas-em-aberto.md` e solicite a confirmação da regra de negócio esperada.
- Uma vez confirmada a regra, atualize a documentação correspondente em `docs/` antes ou junto com a entrega da feature.

