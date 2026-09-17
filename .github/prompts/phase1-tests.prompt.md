---
description: "Use para escrever testes da Fase 1 (unitários do núcleo e integração Qt do transporte): GoogleTest/Qt Test como proposta, registro no CTest. Escrever é permitido; executar, proibido."
agent: "agent"
argument-hint: "Opcional: componente alvo (framing, transport, core)"
---

# Fase 1 — Testes automatizados

Escrever os testes da Fase 1 conforme [plano](../../docs/phase1-bootstrap-transport.md) e [política de validação](../../docs/validation-policy.md). **Escrever testes é permitido; executá-los, nunca** — build, CTest e testes compilados são do responsável/CI.

## Escopo

1. **Unitários (núcleo/enquadramento):** funções puras, determinísticas, sem rede. Matriz de enquadramento: válidas, parciais, concatenadas, truncadas, inválidas, limites.
2. **Integração Qt (transporte):** sinais de conexão/desconexão/erro, ciclo de vida, cancelamento, timeouts — com sockets locais de teste ou mocks; sem servidor real.
3. **Regressão:** toda correção preserva teste do caminho originalmente defeituoso.

## Convenções

- Framework: GoogleTest para núcleo (proposta da Fase 0) e Qt Test para objetos Qt; confirmar com o bootstrap existente antes de adicionar dependências ao `vcpkg.json`.
- Nomes descrevem comportamento, não implementação: métodos Qt em lowerCamelCase (`partialReadProducesIncompleteFrame`); identificadores de suíte/caso GoogleTest em PascalCase (`PartialReadProducesIncompleteFrame`), sem nomes genéricos como `test1`.
- Fixtures locais determinísticas; sem dependência de servidor real, banco ou rede externa.
- Sem dados sensíveis em fixtures; sem dumps de procedência desconhecida.
- Registrar cada suíte no CTest via o alvo de testes existente.

## Restrições obrigatórias

- Código novo em inglês, `.clang-format`, [padrões C++](../instructions/cpp.instructions.md).
- Não alterar árvores protegidas do frontend original.
- Não executar build, CTest, testes compilados, cliente ou servidor; não disparar pipelines.
- Não commitar sem solicitação explícita ([política de commits](../instructions/commits.instructions.md)).

## Relatório esperado

- Suítes criadas e cenários cobertos por suíte.
- Dependências adicionadas ao manifesto (se houver) e justificativa.
- Declaração explícita: testes escritos, **não executados**; execução pendente para responsável/CI.
