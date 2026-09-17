---
description: "Use ao preparar, revisar ou executar commits: Conventional Commits em inglês, título de até 72 caracteres por regra do projeto, corpo detalhado e autorização do responsável antes de commitar."
---

# Política de commits

## Quando commitar

- Commits são criados **somente** após solicitação explícita do responsável ou confirmação de que a feature está concluída e aprovada.
- Não commitar automaticamente ao concluir uma tarefa, mesmo que o resultado pareça completo.
- Não commitar mudanças parciais, não verificadas ou com bloqueios conhecidos sem autorização explícita.
- Não commitar sem o responsável revisar o diff quando ele solicitar revisão prévia.
- Não usar commit para contornar proibições: build, testes compilados, execução do cliente/servidor e alteração do frontend original permanecem proibidos e nunca são "validados por commit".
- Não fazer push, force-push, rebase público, tag ou publicação sem solicitação específica.

## Formato: Conventional Commits em inglês

- Tipo obrigatório: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `revert`.
- Escopo opcional entre parênteses, em inglês, minúsculas: `feat(protocol):`, `fix(session):`.
- Marcar breaking change com `!` após tipo/escopo e explicar no corpo.
- Assunto e corpo estritamente em inglês. Assunto em modo imperativo, sem ponto final: `add session state machine`, não `added session state machine`.

## Título (primeira linha)

- Limite adotado pelo projeto: título **≤ 72 caracteres**, preferindo **≤ 50** para legibilidade. Não é um limite rígido universal do GitHub nem garantia de ausência de truncamento em todas as telas.
- Formato: `<type>(<scope>): <subject>`.
- Sem período final, sem capitalizar a primeira letra do assunto além do necessário.
- Se o assunto não couber com clareza, o escopo está largo demais: dividir o commit.

## Corpo (descrição detalhada)

- Separar assunto e corpo por uma linha em branco.
- Explicar **o que** mudou, **por que** e **quais limitações** permanecem; não narrar o diff linha a linha.
- Linhas com no máximo **72 caracteres**.
- Incluir quando aplicável:
  - motivação e contexto (problema, requisito, fase do plano);
  - decisão técnica relevante e alternativas descartadas, se não óbvias;
  - impacto em contratos do frontend original (deve ser "nenhum" para alterações do motor);
  - validações realmente realizadas e pendências (build/testes manuais pendentes);
  - referências a documentos do plano, issues ou discussões.
- Quebras de página/rodapés: usar convenção do Conventional Commits (`BREAKING CHANGE:`, `Refs:`, `Closes:`).
- Não incluir segredos, tokens, credenciais, caminhos pessoais ou dados sensíveis no corpo.

## Exemplos

Bom:

```text
feat(protocol): add 15.25 message framing decoder

Implement incremental decoder for the 15.25 wire contract:
- preserve message boundaries across partial TCP reads
- reject oversized frames with explicit protocol errors
- cover valid, truncated and concatenated inputs in unit tests

Build and integration tests remain pending for the owner/CI.
Refs: docs/project-plan-2026-09-17.md (phase 1)
```

Ruim:

```text
update stuff
```

```text
fix: fixed the bug and also refactored everything, WIP, please review
```

## Checklist antes de commitar

1. Solicitação explícita do responsável ou confirmação da feature aprovada.
2. Diff revisado; nenhuma alteração nos originais protegidos (`data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/`, `message.txt`).
3. Nenhum arquivo gerado por build, artefato temporário ou segredo incluído.
4. Título dentro do limite, corpo detalhado e em inglês.
5. Limitações e validações pendentes declaradas no corpo, sem alegar build/testes executados.
