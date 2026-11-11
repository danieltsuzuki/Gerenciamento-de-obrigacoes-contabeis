# SPEC-038 — Implementar tema claro e escuro no Flutter

| Campo | Valor |
|---|---|
| Projeto | Gerenciador de Obrigações Contábeis |
| ID Trello | — (card a criar) |
| Card | — |
| Status | Backlog |
| Versão da SPEC | 1.0 |
| Situação da especificação | Draft |
| Tipo | Diferencial (não obrigatório) — **Tema claro e escuro** |

## 1. Objetivo

Oferecer temas claro e escuro com alternância pelo usuário.

## 2. Situação atual

- **Ausente** — `AppTheme` define apenas tema claro; não há `darkTheme` nem `ThemeMode`.

## 3. Escopo funcional

- [ ] `AppTheme.light` e `AppTheme.dark` a partir do mesmo `ColorScheme.fromSeed` (Material 3).
- [ ] Opções: Sistema (padrão), Claro, Escuro.
- [ ] Alternador acessível no `AppScaffold` (AppBar/NavigationRail) com ícone e tooltip.
- [ ] Persistir preferência localmente (armazenamento já usado pelo app ou `shared_preferences`).
- [ ] Revisar cores fixas: chips de status (Pendente/Em andamento/Concluída), avatares e badges devem ter contraste adequado (WCAG AA) nos dois temas.
- [ ] Status continua facilmente identificável visualmente (cor + ícone + texto).

## 4. Regras e restrições

- Sem cores hardcoded fora do tema/`ColorScheme`/extensões de tema.
- Não depender de API.

## 5. Critérios de aceitação

- [ ] Alternância aplica o tema imediatamente e persiste após reiniciar.
- [ ] Testes de widget renderizando telas principais nos dois temas.
- [ ] `flutter analyze` sem issues.

## 6. Cenários de teste

- **Sucesso:** alternar para escuro → `Theme.of(context).brightness == Brightness.dark`.
- **Validação:** preferência inválida/ausente → Sistema.
- **Falha de dependência:** falha ao ler preferência → tema padrão sem exceção.
- **Regressão:** chips de status mantêm rótulos e ícones.

## 7. Dependências

- SPEC-013, SPEC-015.

## 8. Pendências

- Nenhuma.

## 9. Rastreabilidade

- `frontend/README.md`.

