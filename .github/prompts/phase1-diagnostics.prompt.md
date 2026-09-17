---
description: "Use para criar o executável de diagnóstico headless da Fase 1: CLI sem QML para exercitar transporte e enquadramento contra o servidor local. Não executar o binário nem build."
agent: "agent"
argument-hint: "Opcional: subcomando (connect, inspect-fixture, simulate-stream)"
---

# Fase 1 — Diagnóstico headless

Implementar o executável `diagnostics` conforme [plano da Fase 1](../../docs/phase1-bootstrap-transport.md), tarefa 1.5. Nome descritivo, sem marca ou prefixo fixo. É um CLI sem interface gráfica, sem QML, que compõe transporte + enquadramento para validação manual pelo responsável.

A composição cria e injeta o adaptador spdlog, configura sinks e encerra o logging ordenadamente. Aplicar Clean Architecture/Clean Code e enums em headers próprios conforme os [padrões](../../docs/coding-standards.md); não expor spdlog ao núcleo nem usar logger global.

## Requisitos

- Subcomandos mínimos:
  - `connect` — conecta/desconecta somente em loopback, sem enviar payload;
  - `inspect-fixture` — analisa uma fixture sintética local offline;
  - `simulate-stream` — fragmenta fixtures em memória, sem rede.
- Não implementar envio hexadecimal arbitrário, varredura de endpoints ou captura de payload real. Entradas malformadas ficam em memória ou em harness local isolado.
- Códigos de saída distintos: sucesso, falha de conexão, timeout, erro de enquadramento, uso incorreto.
- Saída via logging estruturado do projeto, restrita a estados, contadores e erros; sem `printf`/`std::cout` dispersos.
- Proibido registrar credenciais, tokens ou conteúdo de pacotes em logs.
- Configuração lida do arquivo local (fora do Git); sem segredos no código ou nos presets.

## Restrições obrigatórias

- Código novo em inglês, `.clang-format`, [padrões C++](../instructions/cpp.instructions.md).
- Não alterar árvores protegidas do frontend original.
- **Não executar** o diagnóstico, o servidor, build, CTest ou testes compilados — execução é do responsável ([política de validação](../../docs/validation-policy.md)).
- Não usar o diagnóstico para enviar pacotes de login por suposição.
- Não commitar sem solicitação explícita.

## Relatório esperado

- Arquivos criados/alterados e estrutura dos subcomandos.
- Como o responsável deve executar (comandos exatos, sem executá-los).
- Limitações e cenários não cobertos.
