# ADR-0001: Repositories sem operações de exclusão

- Status: Aceita (2026-11-07)
- Contexto: obrigações fiscais e seus anexos formam histórico auditável. Operações de exclusão física expostas por repositories poderiam apagar dados por engano.
- Decisão: os repositories estendem somente `org.springframework.data.repository.Repository` e declaram operações de gravação, leitura e consulta necessárias; nenhum declara método `delete*`.
- Consequências: a inativação usa `active` em empresas e responsáveis, e exclusões administrativas excepcionais precisam passar por uma decisão explícita na camada de infraestrutura.
- Alternativas consideradas: `JpaRepository`/`CrudRepository`, rejeitadas porque expõem operações de exclusão física por padrão.
