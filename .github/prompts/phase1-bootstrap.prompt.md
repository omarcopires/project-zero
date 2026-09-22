---
description: "Use para iniciar a Fase 1: criar a estrutura client/ com CMake por alvo, vcpkg em modo manifesto e presets Windows. Somente escrita de arquivos; nunca configurar, gerar ou compilar."
agent: "agent"
argument-hint: "Opcional: ajustes de escopo ou nomes de alvos"
---

# Fase 1 — Bootstrap do projeto (CMake + vcpkg)

Criar a estrutura inicial do novo motor conforme [plano da Fase 1](../../docs/phase1-bootstrap-transport.md). Esta tarefa é **somente escrita de arquivos**: não executar CMake, presets, Ninja, MSBuild, vcpkg com compilação, CTest ou qualquer build.

## Antes de começar

1. Confirme que a Fase 0 foi concluída: versões de Qt/C++/MSVC/CMake/vcpkg-baseline/triplet fixadas e origem única de Qt decidida. Se não estiverem, pare e registre o bloqueio — não invente versões.
2. Leia as regras: [instruções gerais](../copilot-instructions.md) e [padrões C++](../instructions/cpp.instructions.md).

## Entregas (arquivos novos, fora das árvores protegidas)

1. `CMakeLists.txt` na raiz e módulos em `cmake/` — alvos descritivos separados: `core` (biblioteca), `diagnostics` (executável headless), `unit_tests` (testes). Nenhum arquivo CMake fica em `client/`. Sem marca ou prefixo de repositório. Dependências por alvo seguem Clean Architecture; infraestrutura depende das portas internas, nunca o contrário.
2. `vcpkg.json` na raiz — dependências mínimas, incluindo spdlog, e `builtin-baseline` fixado conforme decisão documentada; nome descritivo do manifesto; não inventar campo de triplet. Apenas declarar, não instalar.
3. `CMakePresets.json` na raiz — um único configure/build/test preset `windows-x64`, Release, com triplet dinâmico na configuração CMake/vcpkg e sem caminhos pessoais. Ninja + MSVC/x64 é a seleção da Fase 0.
4. `client/src/` e `client/tests/` — código e testes mínimos exigidos pelos alvos, sem arquivos de configuração da build.
5. `client/config/local.example.ini` (ou formato equivalente) — exemplo de configuração local; a configuração real fica fora do Git.
6. `client/.gitignore` — artefatos de build, configuração local e logs.

## Restrições obrigatórias

- Código, identificadores e comentários em inglês; seguir `.clang-format` da raiz (não modificá-la).
- Clean Code e Clean Architecture obrigatórios; núcleo sem dependências de Qt/QML, sockets e logging concreto. Spdlog encapsulado na infraestrutura, criado/injetado pela composição; sem logger global.
- Cada enum novo é `enum class` em header próprio nomeado pelo tipo, no módulo responsável. Aplicar [padrões detalhados](../../docs/coding-standards.md), incluindo exceções Qt isoladas e documentadas.
- Não criar, mover ou editar nada em `data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/` ou `message.txt`.
- Não executar configuração, geração, compilação, instalação vcpkg com compilação, CTest ou testes.
- Não fazer commit sem solicitação explícita ([política de commits](../instructions/commits.instructions.md)).

## Relatório esperado

- Arquivos criados e propósito de cada alvo CMake.
- Decisões pendentes (ex.: versões que dependem da Fase 0).
- Declaração explícita de que configure/build/testes ficaram pendentes para o responsável/CI.
