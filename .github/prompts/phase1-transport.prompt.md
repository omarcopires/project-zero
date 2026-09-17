---
description: "Use para implementar a camada de transporte TCP assíncrona do novo motor (Fase 1): conexão, buffers incrementais, timeouts, cancelamento e fechamento limpo. Sem build nem execução."
agent: "agent"
argument-hint: "Opcional: recorte (conexão, buffers, timeouts, fechamento)"
---

# Fase 1 — Transporte TCP assíncrono

Implementar a camada de transporte conforme [plano da Fase 1](../../docs/phase1-bootstrap-transport.md), seção "Arquitetura da camada" e tarefa 1.3. Código novo em `client/src/network/` (ou `client/src/transport/`, conforme o bootstrap existente).

## Requisitos

- Conexão TCP assíncrona; nenhuma operação bloqueante no fluxo principal.
- Buffers de leitura incremental; preservar fronteiras entre leituras parciais.
- Timeouts de conexão e de leitura configuráveis.
- Cancelamento cooperativo; fechamento limpo com notificação de desconexão.
- Ownership e ciclo de vida explícitos: sem referências pendentes após fechamento; sem proprietários concorrentes (smart pointer + parent QObject) sem justificativa documentada.
- Respeitar afinidade de threads Qt: transporte não toca objetos de UI; eventos entregues via sinais/filas apropriadas.
- Erros tipados e contextualizados (rede, timeout, fechamento remoto, cancelamento); nunca converter falha em sucesso silencioso.

## Contratos

- Transporte implementa portas internas usadas pelos casos de uso/diagnóstico; enquadramento puro não depende do socket. A composição integra ambos conforme Clean Architecture.
- Não interpretar conteúdo das mensagens nesta camada (protocolo é fase posterior).
- Logging via adaptador spdlog da infraestrutura, injetado pela composição; sem tipos concretos no núcleo ou logger global. Proibido registrar credenciais/tokens; sem `printf`/`std::cout` dispersos.
- Usar nomes descritivos sem marca/prefixo de repositório e cada `enum class` em header próprio do módulo, conforme os [padrões](../../docs/coding-standards.md).

## Restrições obrigatórias

- Código novo em inglês, seguindo `.clang-format` e [padrões C++](../instructions/cpp.instructions.md).
- Não alterar `data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/`, `message.txt`.
- Não executar build, CTest, testes compilados, cliente ou servidor. Escrever testes é permitido; executá-los, não.
- Não commitar sem solicitação explícita ([política de commits](../instructions/commits.instructions.md)).

## Relatório esperado

- Arquivos criados/alterados e responsabilidades.
- Decisões de ownership, threads e cancelamento.
- Testes escritos (não executados) e cenários cobertos.
- Pendências de build/validação para o responsável/CI.
