---
description: "Use para implementar o enquadramento de mensagens 15.25 (Fase 1): funções puras sobre buffers, limites de mensagem, erros tipados e matriz de testes. Sem build nem execução."
agent: "agent"
argument-hint: "Opcional: aspecto específico (leitura, escrita, limites, erros)"
---

# Fase 1 — Enquadramento 15.25

Implementar o enquadramento de mensagens conforme [plano da Fase 1](../../docs/phase1-bootstrap-transport.md), tarefa 1.4. O contrato é o definido na Fase 0 (perfil Current 15.25 do servidor em `E:\caverot-server`); **não inferar o formato por suposição** — se um detalhe do contrato não estiver documentado, pare e registre a pendência.

## Requisitos

- Funções puras sobre spans/buffers: determinísticas, sem estado global, testáveis sem rede.
- Leitura incremental: frame incompleto → aguardar mais dados (não é erro); excesso de tamanho → falha tipada; dados inválidos → falha contextualizada.
- Escrita de mensagens conforme contrato (ordem de bytes, tamanhos, limites).
- Sem alocação desnecessária por mensagem; sem cópias evitáveis.
- Erros tipados com contexto suficiente para diagnóstico, sem expor conteúdo sensível.

## Testes a escrever (não executar)

Cobrir a matriz completa em `client/tests/`:

1. mensagem única válida;
2. mensagem parcial (fragmentada em múltiplas leituras);
3. mensagens concatenadas em uma única leitura;
4. mensagem truncada no meio;
5. mensagem inválida (tamanho/campos);
6. limite exato de tamanho (aceito) e limite+1 (rejeitado).

Cada caso com resultado esperado explícito (bytes consumidos, evento produzido, erro tipado).

## Restrições obrigatórias

- Código novo em inglês, `.clang-format`, [padrões C++](../instructions/cpp.instructions.md).
- Não alterar árvores protegidas do frontend original.
- Não executar build, CTest ou testes compilados; validação executável é do responsável/CI ([política de validação](../../docs/validation-policy.md)).
- Não enviar mensagens reais ao servidor para "descobrir" o contrato.
- Não commitar sem solicitação explícita.

## Relatório esperado

- Arquivos criados/alterados e API exposta.
- Suposições de contrato pendentes de confirmação da Fase 0.
- Matriz de testes escritos e cobertura pretendida.
- Pendências de build/execução para o responsável/CI.
