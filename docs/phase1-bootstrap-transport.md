# Fase 1 — Estrutura do núcleo e transporte

Estado: **não iniciada**. Documento de planejamento; nenhum arquivo de código foi criado. Data: 2026-09-17.

## Objetivo

Criar a base executável do novo motor em C++/Qt 6 com CMake + vcpkg e implementar a camada de transporte validada por testes automatizados, **sem interface gráfica** e sem interpretar o protocolo de jogo nesta fase.

## Pré-requisitos (Fase 0)

Esta fase só inicia após a Fase 0 entregar:

- contrato 15.25 confirmado (perfil Current, capacidades e revisão do servidor);
- fluxo HTTP/sessão/TCP documentado nos fontes e vinculado à configuração efetiva utilizada;
- cliente de referência e revisão inspecionada registrados;
- versões fixadas: Qt, C++, MSVC, CMake, vcpkg/baseline, triplet;
- origem única de Qt: **ports vcpkg**, com módulos/features selecionados na Fase 0; resolução e compatibilidade de ABI ainda precisam ser validadas externamente;
- matriz de compatibilidade e inventário inicial de contratos do frontend.

O [encerramento documental da Fase 0](phase0-acceptance.md) registra a base entregue e as ressalvas, conforme replanejamento explícito do plano. O bootstrap sem interface pode avançar; a Fase 1 permanece não iniciada nesta entrega. O contrato global não está fechado: evidência exata do enquadramento é obrigatória antes de implementá-lo. Resolução do baseline, versão do Ninja e compatibilidade da toolchain são gates do aceite externo da Fase 1, não resultados presumidos. Recursos e contratos visuais continuam gates dos incrementos correspondentes.

## Escopo

**Incluído:**

1. Estrutura de projeto `client/` com CMake por alvo, manifesto vcpkg e presets versionados.
2. Núcleo de transporte: conexão TCP assíncrona, enquadramento conforme contrato 15.25, limites de mensagem, leitura incremental, timeouts, cancelamento e fechamento limpo.
3. Executável de diagnóstico headless (sem QML) para exercitar transporte contra o servidor local.
4. Logging estruturado sem credenciais/tokens; configuração local fora do Git.
5. Testes unitários de enquadramento com mensagens sintéticas: válidas, parciais, concatenadas, inválidas e truncadas.
6. Testes de integração Qt para objetos de transporte (sinais, ciclo de vida, threads), quando aplicável.

**Excluído (fases posteriores):**

- interpretação de mensagens de login/jogo (Fase 2+);
- estado de mundo, sprites, renderização (Fase 3+);
- qualquer alteração no frontend original — permanece byte a byte imutável;
- execução de build/testes pelo agente (sempre proibido; ver [política de validação](validation-policy.md)).

## Arquitetura da camada

- **Domínio e casos de uso:** regras, resultados e portas internas, independentes de infraestrutura, Qt/QML, sockets e spdlog.
- **Transporte:** adaptador que implementa portas internas; possui conexão, buffers e timers. Não conhece semântica das mensagens.
- **Enquadramento:** processamento puro de buffers, independente do socket e do logging concreto. Entrada parcial exige mais dados; truncamento no EOF e formatos inválidos produzem falhas explícitas.
- **Logging:** adaptador de infraestrutura baseado em spdlog. Porta interna mínima apenas quando houver consumidor real; nenhum singleton global.
- **Diagnóstico/composição:** instancia e injeta os adaptadores, integra transporte e enquadramento e coordena encerramento. Não coloca dependências concretas no núcleo.

Direção de dependências de código: casos de uso → domínio/portas internas; adaptadores → portas internas; composição → casos de uso e adaptadores. Fluxo de eventos em runtime não inverte essa direção.

Todo backend segue [Clean Architecture e Clean Code](coding-standards.md), com nomes descritivos sem marca/prefixo fixo. Cada enum novo é `enum class` em header próprio nomeado pelo tipo e localizado no módulo responsável; exceções Qt ficam isoladas e documentadas no adaptador.

## Entregas e critérios de aceite

| # | Entrega | Critério de aceite (validação do responsável/CI) |
|---|---|---|
| 1.1 | `client/CMakeLists.txt` + presets + `vcpkg.json` | Configure/build reproduzíveis em máquina limpa; sem caminhos pessoais; baseline fixado |
| 1.2 | Biblioteca `core` + alvo de testes | Testes unitários aprovados via CTest; sem dependência de rede |
| 1.3 | Transporte TCP assíncrono | Conecta/desconecta do servidor local sem bloquear; timeouts e cancelamento funcionam |
| 1.4 | Enquadramento 15.25 | Matriz de testes sintéticos aprovada; limites respeitados; erros tipados |
| 1.5 | Diagnóstico headless | Conecta/desconecta em loopback sem enviar payload; analisa fixtures sintéticas offline e encerra limpo |
| 1.6 | Logging estruturado | Nenhum segredo em logs; níveis configuráveis; sem `printf`/`std::cout` dispersos |

**Não é aceite:** conexão TCP estabelecida como evidência de protocolo compatível; testes "passando" sem execução real; sucesso simulado para ocultar dependências ausentes.

## Tarefas detalhadas

### 1.1 — Bootstrap do projeto

- Criar `client/CMakeLists.txt` com alvos descritivos: `core` (biblioteca), `diagnostics` (executável), `unit_tests` (testes); separar `transport`, `protocol` e `logging` conforme consumidores reais. Nunca usar marca ou prefixo derivado de repositório/referência.
- Criar `client/vcpkg.json` com nome descritivo, dependências mínimas incluindo spdlog e `builtin-baseline` fixado. Declarar somente na implementação autorizada; não instalar nesta etapa.
- Criar `client/CMakePresets.json` com presets `windows-debug` e `windows-release` (Ninja + MSVC, x64).
- Definir padrão C++ e flags por alvo; não espalhar flags globais. Dependências concretas ficam privadas aos adaptadores; núcleo não depende de sockets, Qt/QML ou spdlog.
- Configuração local (endpoints, caminhos) em arquivo fora do Git, com exemplo versionado.

### 1.2 — Núcleo e testes

- Estruturar `client/src/core/` com tipos de erro e eventos tipados.
- Extrair regras determinísticas para funções puras testáveis.
- Criar `client/tests/` com GoogleTest para o núcleo e Qt Test para adaptadores, conforme seleção da Fase 0, e registro no CTest.
- Cada correção de regressão preserva teste do caminho defeituoso.

### 1.3 — Transporte

- Implementar conexão TCP assíncrona com Qt Network, conforme seleção da Fase 0; não reabrir a escolha de biblioteca sem nova evidência.
- Buffers de leitura incremental; sem bloquear a thread de UI (não há UI nesta fase, mas o contrato de threads já vale).
- Timeouts de conexão/leitura; cancelamento cooperativo; fechamento limpo e notificação de desconexão.
- Propriedade e ciclo de vida explícitos; sem referências pendentes após fechamento.

### 1.4 — Enquadramento

- Implementar leitura/escrita de mensagens conforme contrato 15.25 (tamanhos, limites, ordem de bytes).
- Funções puras sobre spans/buffers; sem alocação desnecessária por mensagem.
- Erros tipados: frame incompleto (aguardar), excesso de tamanho (falha), dados inválidos (falha contextualizada).
- Testes cobrem: mensagem única, parcial, concatenada, truncada, inválida e limite exato.

### 1.5 — Diagnóstico headless

- CLI com subcomandos propostos: `connect` (conectar/desconectar em loopback sem enviar payload), `inspect-fixture` (analisar fixture sintética local offline) e `simulate-stream` (fragmentar fixtures em memória, sem rede).
- Não incluir envio hexadecimal arbitrário, varredura de endpoints ou captura/dump de payload real. Casos malformados ficam exclusivamente em memória ou em harness local isolado.
- Saída estruturada com estados, contadores e erros, sem conteúdo de pacotes; sem interação com QML.
- Encerramento limpo com códigos de saída distintos para sucesso/falha.

### 1.6 — Logging

- Spdlog é o padrão obrigatório, encapsulado na infraestrutura e configurado/injetado na composição. Não usar logger global nem expor headers/tipos spdlog ao domínio ou aos casos de uso.
- Porta interna mínima somente quando houver consumidor real; regras puras retornam resultados/erros sem logging. Seguir [Clean Architecture, Clean Code e organização de enums](coding-standards.md).
- Aplicar o [formato verificado](coding-standards.md#formato-verificado-na-referência): pattern `[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v`, payload `[FunctionName] - Message` e argumentos com `{}`, não `%d`/`%s`. Função capturada no ponto da chamada; primeira letra ASCII da mensagem em maiúscula.
- Perfil inicial síncrono: console colorido e arquivo simples `debug.log` truncado ao iniciar, flush a partir de trace, info por padrão e debug com `--developer`; arquivo/configuração fora do Git. Sem rotação ou fila assíncrona nesta base; alterações futuras exigem decisão explícita. Versão fixada pelo manifesto/baseline na implementação autorizada.
- Proibido registrar credenciais, tokens ou conteúdo sensível de pacotes. Escrever testes sintéticos de omissão de segredos, falhas de sink e encerramento; execução apenas pelo responsável/CI.

## Verificações da fase (responsável/CI)

1. `cmake --preset windows-debug` e build em máquina limpa — reproduzível.
2. `ctest --preset windows-debug` — todos os testes unitários aprovados.
3. Diagnóstico conecta no servidor local e encerra limpo.
4. Matriz de enquadramento aprovada (válidas/parciais/concatenadas/inválidas/truncadas).
5. Logs sem segredos; configuração local fora do Git.
6. Originais protegidos íntegros (hashes inalterados).

## Riscos específicos

| Risco | Mitigação |
|---|---|
| Contrato 15.25 mal interpretado | Basear-se na Fase 0; não enviar mensagens por suposição |
| Mistura de ABIs Qt | Origem única de Qt; triplet fixado |
| Bloqueio de thread por I/O | I/O assíncrono desde o início; testes de cancelamento |
| Vazamento de segredos em logs | Revisão de logs; testes de sanitização |
| Dependência prematura de QML | Núcleo sem QML nesta fase; integração só na Fase 4 |

## Ordem de trabalho e decisões bloqueantes

Ninja, Qt Network, GoogleTest e Qt Test foram selecionados na [Fase 0](phase0-contract-status.md); o formato de configuração permanece proposto. Usar o Visual Studio 2026/MSVC 14.51.36231 existente, sem exigir MSVC 2022/v143 ou modificar instalações, PATH e checkout compartilhado do vcpkg. Seleção não comprova compatibilidade executável. Nomes descritivos sem marca, spdlog, Clean Architecture/Clean Code e enums separados são regras confirmadas. Os prompts devem conferir o contrato da Fase 0 antes de implementar cada recorte; ausência de evidência bloqueia apenas o recorte dependente, sem inventar valores.

1. **Entrada:** registrar revisões do servidor e do cliente de referência, toolchain e contratos necessários. As revisões inspecionadas, a seleção aprovada e o inventário do ambiente constam no relatório da Fase 0; validação técnica da toolchain e contratos ainda estão pendentes. Leitura estática não encerra a fase.
2. **Bootstrap:** alvos core, transporte, enquadramento, diagnóstico e testes separados por responsabilidade. Configurar dependências por alvo; manter core livre de sockets/QML. Definir a abstração mínima de logging aqui, sem framework genérico desnecessário.
3. **Enquadramento e testes puros:** registrar evidência de campo/ordem de bytes/limite antes de codificar; construir fixtures sintéticas locais. Nunca inferir criptografia, compressão ou integridade a partir do número 15.25; camadas ainda desconhecidas permanecem bloqueadas.
4. **Transporte e testes de lifecycle:** integrar enquadramento por composição no diagnóstico, sem obrigar o socket a interpretar frames. Documentar ownership, afinidade de thread e entrega dos eventos.
5. **Diagnóstico:** compor componentes concluídos; limitar entrada a fixtures offline e conexão passiva em loopback.
6. **Revisão estática:** registrar arquivos, contratos atendidos, bloqueios e verificações realizadas. Não concluir a fase com base apenas nessa revisão.
7. **Aceite externo:** responsável ou CI previamente configurada executa configurações/testes e registra resultados associados à revisão. Nenhum prompt dispara CI ou autoriza commit automático.

### Caminho HTTP confirmado pelo responsável

O fluxo HTTP → sessão → TCP foi identificado nos fontes do cliente e do servidor. O responsável confirmou builds atuais, seleção/login/jogo funcionais e autenticação por sessão com e-mail/senha em `http://127.0.0.1:8080/api/v1/webservice`. A tentativa GET fora do escopo, encerrada em `ConnectFailure`, está registrada no relatório da Fase 0 e não valida autenticação. A identificação exata dos binários fica para o registro externo. Endereço/porta TCP do jogo permanecem pendentes, sem inferência a partir da porta HTTP.

Para esse caminho, a Fase 1 inclui somente a infraestrutura HTTP assíncrona necessária: limites de resposta, deadline, cancelamento, fechamento e classificação de erros. A composição de autenticação, credenciais e interpretação de sessão pertence à Fase 2. O responsável adiou 2FA para depois do incremento inicial: um desafio exigido pelo serviço deve resultar em fluxo não suportado, nunca em sucesso ou bypass. Não seguir redirects para endpoints não autorizados nem implementar fallback automático para login TCP. HTTP sem TLS fica restrito ao laboratório em loopback; exposição externa exige decisão de transporte seguro.

### Contrato operacional mínimo

- Estados propostos: idle, connecting, connected, closing, closed; falhas produzem erro tipado e encerramento observável. Definir transições válidas, fechamento idempotente e um único evento terminal por tentativa.
- Limitar buffers de entrada e fila de saída; definir backpressure, escrita parcial e política explícita para fila cheia. Valores vêm do contrato ou de decisão documentada, não de suposição.
- Distinguir deadline de conexão, inatividade e frame incompleto; cancelar timers no fechamento. Descartar callbacks tardios de tentativas anteriores.
- Frame parcial significa aguardar enquanto o fluxo está aberto; EOF com bytes pendentes significa truncamento. Informar consumo sem perder frames concatenados nem entrar em loop sem progresso.
- Logs usam campos permitidos (evento, estado, categoria de erro, duração e contagens); não registrar payloads, URLs com segredos, headers, credenciais ou tokens. Não prometer sanitização sem teste externo.

## Matriz de testes e registro de aceite

Todos os testes abaixo serão **escritos**, não executados pelo agente.

| Área | Casos mínimos | Resultado esperado |
|---|---|---|
| Enquadramento | vazio, header/body parcial, cortes em cada posição, múltiplos frames e sobra | sem perda/duplicação; consumo e necessidade de dados explícitos |
| Limites | mínimo documentado, máximo, máximo+1, comprimento inválido, overflow | rejeição controlada antes de alocação excessiva |
| EOF | fronteira completa ou fragmento pendente | fechamento normal ou erro de truncamento, respectivamente |
| Escrita | escrita parcial, fila cheia, cancelamento | ordem preservada, backpressure e término explícitos |
| Lifecycle | recusa, timeout, fechamento remoto, cancelamento em cada estado, fechamento repetido | sem callbacks pendentes utilizáveis, sem evento terminal duplicado |
| Threads | callbacks tardios e destruição do dono | nenhum acesso após destruição; entrega na thread definida |
| HTTP, se exigido | resposta fragmentada, limite, timeout e redirect não autorizado | falha tipada; nenhuma autenticação implementada nesta fase |
| Logs/configuração | campos sintéticos sensíveis, erro e configuração inválida | segredos ausentes; erro explícito, sem fallback silencioso |
| Diagnóstico | fixture válida/inválida, argumentos inválidos, encerramento | códigos de saída documentados; sem envio arbitrário |

Preferir relógio/controlador de I/O injetável para regras determinísticas; separar testes Qt com sockets de loopback dos testes puros. Não usar sleeps como sincronização nem servidor real na suíte unitária.

O registro de aceite, a preencher futuramente pelo responsável, deve conter: revisão, ambiente/toolchain, configuração, suíte/cenário, resultado real, referência ao relatório sanitizado, conferência de hashes e bloqueios. Estado inicial de todos os critérios executáveis: **pendente**.

### Automação e reprodutibilidade

Planejar CI Windows desde esta fase: checkout, toolchain fixada, configure/build, CTest, relatórios sanitizados e conferência dos originais. É apenas desenho documental; nenhum workflow foi criado ou disparado. Uma futura criação de workflow requer solicitação própria e revisão do responsável, especialmente dos gatilhos. Cache não substitui baseline nem validação em máquina limpa.

Presets de configuração, build e teste devem ser declarados separadamente, com diretório fonte `client/` e nomes coerentes; a existência de um configure preset não cria automaticamente um test preset. O triplet pertence à configuração CMake/vcpkg, não a um campo inventado no manifesto. Comandos de validação anteriores são exemplos futuros, ainda não verificados.

## Prompts desta fase

Prompts reutilizáveis em `.github/prompts/`, acessíveis digitando `/phase1-` no chat ou pela ação **Chat: Run Prompt...**. Selecionar um prompt não satisfaz seus pré-requisitos nem autoriza operações proibidas. Ordem sugerida: bootstrap → framing → transport → diagnostics, usando tests em cada incremento.

Cada prompt deve consultar este roteiro, relatar evidências e parar o recorte se seu contrato estiver ausente. Argumentos opcionais refinam escopo, sem revogar regras.

Prompts disponíveis:

- [phase1-bootstrap](../.github/prompts/phase1-bootstrap.prompt.md) — criar estrutura CMake/vcpkg/presets.
- [phase1-transport](../.github/prompts/phase1-transport.prompt.md) — implementar transporte TCP assíncrono.
- [phase1-framing](../.github/prompts/phase1-framing.prompt.md) — implementar enquadramento 15.25.
- [phase1-diagnostics](../.github/prompts/phase1-diagnostics.prompt.md) — executável headless de diagnóstico.
- [phase1-tests](../.github/prompts/phase1-tests.prompt.md) — escrever testes unitários e de integração Qt.

Todos os prompts respeitam as [regras gerais](../.github/copilot-instructions.md): nenhum build, teste compilado ou execução pelo agente; frontend original imutável.
