# Questões em aberto — não presumir

Os documentos do projeto listam estes pontos sem decisão definitiva:

1. É permitido remover ou substituir anexos de uma obrigação `COMPLETED`?
2. Há autorização por perfil/papel ou apenas autenticação? Por exemplo, somente o responsável atribuído pode avançar status?
3. Obrigações são avulsas ou possuem periodicidade/recorrência automática?
4. Deve existir estado derivado `atrasada`, calculado pelo prazo, sem novo valor no enum?
5. A política de limite de tamanho e tipos MIME de anexos precisa ser consolidada: `CHANGELOG.md` registra 10 MB e a API enumera categorias de arquivos, mas a lista de pendências ainda solicita confirmação.
6. O modelo atual valida CNPJ numérico de 14 dígitos. Suporte a CNPJ alfanumérico não está definido.
7. A busca por intervalo de vencimento precisa de confirmação sobre inclusividade dos limites `dueFrom`/`dueTo`.
8. Confirmar estratégia de execução dos testes de integração em ambientes sem Docker, pois Testcontainers depende do ambiente.

Quando uma tarefa depender de qualquer item acima, faça uma pergunta objetiva antes de implementar. Se a tarefa não depender, não bloqueie o trabalho.
