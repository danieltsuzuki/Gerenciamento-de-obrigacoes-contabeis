# Pendências e perguntas em aberto

## Pendências e perguntas herdadas

- Pode remover ou substituir anexos de uma obrigação `COMPLETED`?
- Existe perfil/autorização (ex.: só o responsável avança o status) ou só autenticação básica?
- A obrigação tem periodicidade/recorrência automática (mensal, anual) ou cada uma é avulsa?
- Haverá status derivado "atrasada" (prazo vencido) calculado em consulta, sem novo valor no enum?
- Limite de tamanho e tipos MIME aceitos para anexos.
- CNPJ alfanumérico da Receita Federal: manter validação extensível quando for implementada.

## Pendências e perguntas desta tarefa

- A autenticação ainda não existe; a coluna `users.password` recebe `passwordHash` e o hash será tratado em tarefa futura.
- Validadores de CNPJ, e-mail e demais regras de entrada serão implementados em services futuros.
- Definir se a busca por intervalo de vencimento deve aceitar limites inclusivos diferentes de `dueFrom`/`dueTo`.
- Confirmar a estratégia de testes em ambientes sem Docker, pois os testes de integração dependem de Testcontainers MySQL 8.
