# Plano do novo cliente

Data-base: 2026-09-17. Estado atualizado em 2026-09-24: plano-base aprovado; Fase 0 documental concluída com ressalvas; Fase 1 validada externamente; Fase 2 de protocolo/sessão concluída pelos incrementos aceitos até aqui; Fase 3 em andamento; bootstrap visual da Fase 4 iniciado. Este documento consolida o planejamento, a preservação integral do frontend original e os gates técnicos explícitos.

## 1. Decisões confirmadas

- Núcleo novo em **C++ e Qt 6**, inicialmente Windows.
- Nomes descritivos por responsabilidade, sem marca ou prefixo fixo em pastas, arquivos, namespaces, manifesto, alvos e executáveis. Caminhos externos históricos permanecem referências, não nomes do projeto; não renomear a raiz.
- **Clean Architecture e Clean Code** obrigatórios em todo backend. Domínio/casos de uso independentes de infraestrutura; adaptadores dependem das portas internas e são injetados na composição.
- **Spdlog** como padrão de logging, encapsulado na infraestrutura, sem dependência concreta no domínio/casos de uso e sem logger global. Versão/baseline serão fixadas na implementação autorizada.
- Cada enum novo é **enum class em header próprio**, nomeado pelo tipo e no módulo responsável. Adaptações Qt/QML isoladas, com exceções documentadas sem alterar originais.
- **CMake + vcpkg**, modo manifesto, baseline e triplet fixados, presets versionados e configuração local sem segredos no Git.
- Testes automatizados desde o início. Configuração, build, testes compilados e execução real são responsabilidade do responsável ou CI previamente configurada, nunca do agente.
- **Suporte exclusivo a 15.25** do servidor de desenvolvimento em `E:\caverot-server`. Não seguir automaticamente versões futuras nem incluir compatibilidade antiga.
- OTClient apenas como referência; não adotar seu núcleo ou sua arquitetura Lua/OTUI.
- Conexão e sessão antes da integração visual completa.
- MVP: login, seleção de personagem, mapa, movimento, chat, inventário e combate básico.
- Projeto fechado, com acesso restrito ao responsável. Uma eventual abertura ou publicação será decidida por ele no futuro, fora do escopo atual.
- Nenhum prazo prometido antes de fechar referências, recursos, equipe e disponibilidade.

### Regra central: frontend original imutável

Preservar byte a byte `data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/` e `message.txt`. Não editar, formatar, normalizar finais de linha, renomear, mover, excluir, converter, substituir ou gerar arquivos nessas árvores.

O motor novo deve atender ao frontend existente, e não o contrário. Proibido contornar essa regra com cópias modificadas, patches de build, substituição em runtime ou componentes de mesmo nome que alterem o comportamento da apresentação. Não converter QML para OTUI.

Implementar compatibilidade exclusivamente em C++/Qt novo, adaptadores, modelos, tipos nativos ausentes, providers e mapeamentos externos de recursos. Se um contrato não puder ser preservado, registrar o bloqueio e interromper a funcionalidade afetada; não modificar o QML.

Essa regra substitui a sugestão inicial de construir uma apresentação alternativa ou adaptar componentes QML. Um hospedeiro ou harness auxiliar separado pode instanciar componentes originais sem alterá-los, mas não substituir a interface do jogo. Componentes invisíveis também podem exigir tipos resolvidos e dependências completas.

## 2. Evidências e pendências

### Servidor de desenvolvimento

Resultados de inspeção somente leitura da fase de planejamento, não validação do executável:

| Referência em `E:\caverot-server` | Evidência / consequência |
|---|---|
| `src/core.hpp` | Declara Canary 3.6.1 e `CLIENT_VERSION = 1525`; não comprova versão do binário em uso |
| `src/server/network/protocol/protocol_profile.cpp` | Perfis e capacidades distintos; apenas Current/15.25 entra no escopo |
| `src/server/network/protocol/protocolgame.cpp` | `supportsWeaponProficiencyDetailList` e `shouldSendWeaponProficiencyDetailList` distinguem capacidades dentro de 15.25 |
| `config/session_auth.lua` | Declara autenticação por sessão; configuração efetiva e precedência pendentes |
| `config/http.lua` | Habilita HTTP/8080 no fragmento inspecionado; não confirma serviço em execução |
| `src/server/network/http/routes.cpp` e `webservice/handlers/login_handler.cpp` | Caminho de autenticação HTTP, sessão, mundos e personagens |
| `src/io/iologindata.cpp` | `gameWorldAuthentication` valida sessão e associação personagem-conta |
| `src/server/network/protocol/protocollogin.cpp` | Também existe login TCP; não presumir intercambialidade com HTTP |
| `src/protobuf/appearances.proto`, `data/items/appearances.dat`, `data/items/items.xml` | Metadados/IDs, não pacote gráfico completo |
| `CMakePresets.json`, `cmake/modules/BaseConfig.cmake` | Servidor usa toolchain Windows/MSVC/vcpkg e C++23; não herdar automaticamente padrão ou toolset do cliente |
| `tests/README.md` e `tests/unit/server/network/protocol/multiprotocol_test.cpp` | Testes úteis como referência; não executados. Integração pode recriar banco |

O fluxo **HTTP → sessão → conexão de jogo TCP** foi rastreado e confirmado pelo responsável: sessão com e-mail/senha, API `http://127.0.0.1:8080/api/v1/webservice` e mundo `localhost:7172`. Login TCP 7171 também informado, sem intercambialidade automática com HTTP. Não enviar mensagens de login por suposição. O serviço HTTP inspecionado usa `httplib::Server`, sem TLS nativo evidenciado nesse trecho; manter laboratório em loopback. Qualquer exposição futura exige transporte seguro planejado.

Não foram abertos arquivos ativos potencialmente contendo credenciais, bancos, chaves ou logs. O número 15.25 não resolve sozinho capacidades, formato dos assets ou revisão de conteúdo.

### Frontend e recursos

A [auditoria](backend-resource-audit.md) encontrou recursos Qt, código QML/JS e descritores de integração; não encontrou o núcleo nativo implementado. Faltam tipos como `WorldMap`/`LightMap`, contratos de controllers, modelos ativos e providers.

A quantidade de imagens não demonstra a presença de sprites de mundo compatíveis. Catálogos de traduções, aliases e associação entre IDs e aparências precisam ser verificados. O pacote local de recursos Qt não substitui uma distribuição válida do SDK/runtime.

### Decisões fixadas e verificações restantes

Estado da Fase 0: [encerramento documental com ressalvas](phase0-acceptance.md). O responsável confirmou o funcionamento de `E:\caverot-client`, cliente que mantém e referência funcional desta etapa, com executáveis nas últimas modificações. HEADs reconferidos; não se aguarda outra URL nem se adota o motor antigo.

1. Laboratório e autenticação confirmados por relato; capacidades e formatos restantes devem ser rastreados antes dos respectivos incrementos, sem exigir nova confirmação geral de login/jogo.
2. Fixados: C++20, Qt 6.11.1, MSVC 14.51.36231, CMake 4.3.1-msvc1, baseline vcpkg `fa8cecf91d7f31a1715a7a6524f208897ffb33ce`, `x64-windows` dinâmico. Backend gráfico permanece posterior; Ninja instalado, versão ainda não identificada.
3. Origem única de Qt: **ports vcpkg**, módulos/features selecionados no relatório. Resolução e ABI não validadas externamente; objeto de baseline não resolvido na consulta local. Não misturar com SDK externo ou alterar ambiente por suposição.
4. Sprites e metadados locais inventariados; todas as referências do catálogo existem, mas aparências diferem do servidor. Traduções não localizadas; fontes do Windows presentes, sem validação gráfica. Correspondência de IDs é gate de recursos.
5. Equipe, disponibilidade e orçamento de desempenho não fundamentam promessa de prazo; metas de desempenho dependem de baseline futuro.

A ausência de um recurso deve ser registrada como bloqueio técnico, nunca usada como justificativa para substituir ou alterar o frontend protegido.

## 3. Arquitetura

| Camada | Responsabilidade e limites |
|---|---|
| Transporte | I/O assíncrono, enquadramento conforme contrato, limites, timeouts, cancelamento e encerramento |
| Protocolo 15.25 | Conversão entre dados de rede e eventos/comandos tipados; sem UI e sem compatibilidade automática |
| Sessão | Autenticação, personagens, transição de endpoints se aplicável e ciclo de vida |
| Domínio | Jogador, tiles, criaturas, itens, chat e combate; regras determinísticas independentes de QML |
| Integração Qt | QObject, propriedades, sinais, roles, modelos e comandos compatíveis com os consumidores originais |
| Recursos | Catálogos, aparências, URLs, aliases e providers; originais somente leitura |
| Renderização | Câmera, ordem visual, sprites, animação, luz e composição Qt Quick |
| Apresentação | QML original, mantido integralmente; recebe estado e encaminha intenções conforme seu contrato existente |

Não impor independência de todo o Qt ao MVP, mas manter sockets, decodificação e regras fora da apresentação. Não importar singletons da engine antiga. Preferir interfaces pequenas com consumidores reais.

Definir ownership e cancelamento explicitamente. Objetos QML/Qt são atualizados na thread apropriada; o renderizador consome estado sincronizado sem compartilhamento arbitrário de objetos mutáveis. Diferenciar comando enviado de alteração confirmada pelo servidor. Não converter erros em sucesso aparente.

A fronteira gráfica proposta é um item integrado ao Qt Quick, compatível com a composição e captura exigidas pelo QML. Não presumir que um renderizador OpenGL externo substitua um item Qt Quick ou que o backend gráfico original esteja conhecido. Validar a solução pelo responsável/CI antes de expandi-la.

## 4. Marcos e critérios de aceite

**Todos os critérios executáveis abaixo são validações futuras do responsável ou CI previamente configurada. Não são autorização para agentes executarem build, cliente, servidor ou testes.** Ver [política](validation-policy.md).

### Fase 0 — Contrato, recursos e toolchain

**Dependências:** nenhuma implementação prévia.

- Confirmar revisão, perfil Current 15.25 e capacidades do servidor, sem abrir segredos.
- Documentar fluxo real de autenticação, endpoints de laboratório e dados de teste.
- Registrar revisão e capacidades da referência funcional; não presumir que qualquer fork suporte o contrato.
- Produzir matriz: funcionalidade, evidência no servidor, referência, fixture, contrato QML e critério de aceite.
- Inventariar tipos nativos, controllers, propriedades, métodos, sinais, roles, providers e aliases exigidos pelo recorte inicial.
- Verificar disponibilidade, formato e correspondência dos QMLs, imagens, fontes, sprites e traduções.
- Fixar toolchain, formato de assets e origem de Qt, preservando `.clang-format` e originais.

**Entrega:** contrato 15.25, matriz de compatibilidade, inventário de recursos/integração e decisões de toolchain.

**Aceite documental:** ambiente e fluxo documentados; reprodução real do servidor confirmada pelo responsável; bloqueios de recursos explicitados. Após a solicitação de finalizar a etapa e as confirmações finais, a entrega documental foi encerrada com ressalvas em 2026-09-17. Não se afirma contrato global completo nem aceite técnico.

**Replanejamento explícito:** bootstrap sem interface pode avançar a partir da base documentada. Validação de toolchain é gate do aceite da Fase 1; evidência do formato é obrigatória antes de implementar seu enquadramento; correspondência de assets antes dos recursos da Fase 3; contratos transitivos, fontes/traduções e plugins antes da integração da Fase 4; bloqueio de chat mantido para o caminho afetado da Fase 5. Os critérios detalhados estão no [termo](phase0-acceptance.md). Nada disso autoriza build pelo agente ou afirmação de validações não realizadas.

### Fase 1 — Estrutura do núcleo e transporte

**Depende de:** fase 0.

Detalhamento, ordem de trabalho, matriz de testes e prompts reutilizáveis: [documentação da Fase 1](phase1-bootstrap-transport.md). A documentação não encerra a Fase 0 nem autoriza implementação sem os pré-requisitos.

- Criar configuração CMake por alvo, manifesto vcpkg e presets, sem gerar artefatos pelo agente.
- Separar núcleo, transporte e testes; preparar executável de diagnóstico sem interface gráfica.
- Implementar apenas os transportes necessários ao caminho confirmado, limites, processamento incremental, timeout, cancelamento e fechamento limpo.
- Logging estruturado sem credenciais/tokens; configuração local fora do Git.
- Escrever testes sintéticos locais para mensagens válidas, parciais, concatenadas, inválidas e truncadas; falhas devem ser controladas.

**Aceite externo:** configuração/build reproduzíveis, testes unitários aprovados, transporte conecta/desconecta no laboratório sem bloquear o processo e reporta erros. Conexão TCP não é evidência de login compatível.

### Fase 2 — Autenticação e sessão mínima

**Depende de:** fase 1.

- Implementar o fluxo verificado, lista/seleção de personagem, transição de endpoint se aplicável, entrada e encerramento de sessão.
- Máquina de estados explícita; distinguir erros de transporte, autenticação, incompatibilidade e cancelamento.
- Usar apenas conta de teste e serviços locais controlados. Não contornar autenticação ou proteções.

**Aceite externo:** diagnóstico recebe confirmação real de entrada no mundo; testar credencial inválida, indisponibilidade, incompatibilidade e desconexão durante autenticação. Seleção local de personagem não conta como ingresso confirmado.

### Fase 3 — Estado inicial de mundo e recursos mínimos

**Depende de:** fase 2.

- Modelar posição, tiles, criaturas, jogador e IDs de aparências sem depender de QML.
- Implementar eventos do estado inicial e atualizações básicas; manter comandos e confirmação do servidor distintos.
- Carregar metadados e recursos autorizados correspondentes ao alvo. Ausência de recurso deve produzir erro explícito ou comportamento de falha documentado, não estado falso de sucesso.
- Escrever testes determinísticos de aplicação de eventos e limpeza de sessão.

**Aceite externo:** diagnóstico demonstra estado inicial coerente e atualização de posição confirmada pelo servidor, com testes determinísticos aprovados.

### Fase 4 — Integração do frontend original e mapa mínimo

**Depende de:** fase 3 para integração real; inventário de contratos pode avançar em paralelo após fase 0.

- Carregar progressivamente componentes originais através de host separado, sem alterar ou substituir nenhum QML existente.
- Implementar os tipos/controllers/modelos efetivamente exigidos, com nomes e semântica preservados. Não preencher métodos com sucesso simulado para ocultar dependências.
- Reproduzir o contrato de composição de `clientwindow.qml` e integração de `gamewindow.qml`. Instanciar a tela inteira somente quando as dependências de criação estiverem atendidas.
- Registrar tipos nativos ausentes, enums, traduções, providers e mapeamentos externos. Não editar descritores `qmldir` originais.
- Implementar mapa integrado ao Qt Quick preservando camadas de `MapWindowPane.qml`: cenário, iluminação, HUD e entrada.
- Validar coordenadas, clipping, DPI e backend gráfico; não presumir ganho de performance ou fidelidade sem medição.

**Aceite externo:** autenticar, escolher personagem e visualizar mapa real no frontend original; sem erros obrigatórios de tipos/imports/recursos; clique e desenho alinhados em 100%, 150% e 200%; originais íntegros.

Se o carregamento exigir dependências ainda não implementadas, isso aumenta o marco ou o bloqueia. Não autoriza simplificar telas, ocultar alterações em uma cópia ou adotar frontend substituto.

### Fase 5 — MVP jogável

**Depende de:** fase 4.

Entregar incrementos pequenos na ordem:

1. Movimento e correções do servidor.
2. Chat, histórico e modelos compatíveis.
3. Inventário, containers e operações mínimas de itens.
4. Seleção de alvo, ataque básico e estado de combate.

Para cada incremento: evidência no servidor → eventos/domínio → adaptador Qt → integração da tela original → testes. `ChatOutput.qml` exige medição/seleção no modelo; `container.qml` exige helpers, roles e notificações específicos. Não tratá-los como listas passivas.

**Aceite externo:** dois clientes de teste demonstram movimento observado, chat, itens e combate com estados consistentes. Recursos fora do MVP não são implementados silenciosamente como sucesso; limitações ficam explícitas no host/contrato e na documentação, sem alterar telas originais.

### Fase 6 — Estabilização e empacotamento privado

**Depende de:** fase 5; planejamento de automação começa na fase 1.

- Build/testes automatizados Windows e empacotamento Qt, acionados externamente ao agente.
- Sessões prolongadas, interrupção de rede, cancelamento, limpeza de estado e consumo de memória.
- Medir desempenho em máquina/cena/backend definidos; fixar metas após baseline.
- Incluir instruções de ambiente de teste.
- Validar instalação em máquina limpa sem depender de uma instalação do cliente original.
- Conferir que os originais empacotados correspondem byte a byte aos aprovados.

**Aceite externo:** pacote privado reproduzível, testes e limitações documentados, recursos íntegros e fidelidade/estabilidade demonstradas nos cenários definidos. Publicação não faz parte deste marco.

## 5. Estratégia de testes e engenharia

- Proposta: GoogleTest para regras de núcleo e Qt Test/Qt Quick Test para integração; decisão final na fase 0.
- CTest como orquestrador proposto; nenhuma suíte criada ou executada nesta etapa documental.
- Unitários independentes de servidor; integração com servidor/banco descartáveis em fluxo separado, nunca banco de trabalho.
- Fixtures locais determinísticas; não usar dumps de origem desconhecida nem capturas contendo credenciais.
- Verificar propriedades, sinais, roles, notificações, lifecycle e threads além do valor visual final.
- Separar testes de correção, benchmarks e testes ponta a ponta.
- Toda regressão deve preservar evidência verificável do caminho defeituoso. Testes escritos não equivalem a testes aprovados.
- Agentes podem fazer leitura, diff, hashes e diagnóstico estático; não executar configurações, builds, CTest, cliente, servidor ou pipelines.

## 6. Organização futura proposta

A organização inicialmente proposta foi atualizada quando o bootstrap começou em 2026-09-22: arquivos de entrada da build permanecem na raiz, módulos auxiliares ficam em `cmake/` e `client/` contém código, testes e configuração de execução.

| Caminho proposto | Responsabilidade |
|---|---|
| `CMakeLists.txt` e `cmake/` | Entrada na raiz e módulos com alvos/opções/testes separados |
| `CMakePresets.json` | Configurações reproduzíveis Windows, sem caminhos pessoais |
| `vcpkg.json` | Dependências e baseline fixado |
| `client/src/core/` | Domínio e regras |
| `client/src/network/` | Transporte |
| `client/src/protocol/` | Contrato exclusivo 15.25 |
| `client/src/session/` | Sessão e casos de uso |
| `client/src/qtbridge/` | Tipos, controllers, modelos e adaptação Qt |
| `client/src/render/` | Renderização e sincronização |
| `client/resources/` | Manifestos/aliases externos e recursos novos autorizados, sem cópias modificadas dos originais |
| `client/tests/` | Testes e harnesses isolados |
| `.github/workflows/client-ci.yml` | Possível CI Windows futura, não criada nem disparada |

Não criar uma árvore `client/qml/` para reimplementar ou substituir o frontend do jogo. Se necessário, um harness separado apenas hospeda os componentes originais e testa contratos, sem alterar sua semântica. Não duplicar ou substituir a `.clang-format` da raiz.

## 7. Riscos e limites do MVP

| Risco | Tratamento |
|---|---|
| Fork OTClient incompatível com o servidor | Fixar referência verificável; servidor é contrato efetivo |
| Diferenças dentro de 15.25 | Fixar revisão/capacidades, não só número |
| QML depende de tipos nativos ausentes | Inventário e adaptação compatível; nunca editar frontend |
| Sprites/traduções/aliases incompletos | Bloqueio explícito, inventário e metadados autorizados |
| Mistura de runtimes/ABIs Qt | Origem e versões únicas, validação externa |
| Corridas de thread e lifecycle | Ownership, eventos tipados e sincronização testáveis |
| Regras confundidas com bloqueio técnico | Revisão e hashes; não alegar proteção automática |

Fora do MVP: versões antigas/futuras, serviços oficiais, loja/pagamentos, criação web de contas, atualizador automático, todos os sistemas avançados (Forge/Prey/Bosstiary etc.) e multiplataforma. Os componentes dessas funcionalidades permanecem preservados, mesmo sem implementação correspondente no MVP.

## 8. Próximos passos e estado real

Atividade de engenharia atual: Fase 3 — estado inicial do mundo e recursos mínimos, em paralelo ao bootstrap visual da Fase 4. O responsável reportou 145/145 testes aprovados após a adição do decoder LZMA-Alone, e iniciou `client_app`; a janela original de espera carrega sem erros QML de recursos no último log compartilhado. Para as chaves não resolvidas da captura, foi extraído o catálogo completo disponível no arquivo local `client.en.qm`: 4.622 entradas inglesas para IDs, sem duplicatas. O script reproduzível `tools/extract_qm_catalog.py` gera `client/translations/en.json`, registra SHA-256 e não altera a instalação de origem. O tradutor C++ carrega esse catálogo antes do QML; o teste de integração foi atualizado para verificar IDs reais e aguarda validação externa. O artefato compilado não contém metadados nem mensagens não publicadas do `.ts` original; cobertura das strings fora do QM continua pendente. Persiste um aviso Qt de propriedade `enabled` duplicada em `TooltipBase`. O QML original é preservado byte a byte. O executável empacota QMLs e imagens originais nos caminhos Qt e carrega `clientwindow.qml` por `QQmlApplicationEngine`; ela não instancia `gamewindow.qml`, portanto ainda não é a tela de login. O teste `qml_integration.loadsOriginalClientWindow` cobre os recursos e a janela raiz. O adaptador `qmlenumvalues` expõe os três modos de redimensionamento de `GamewindowSplitView.qml` e os três modos de antialiasing de `MapWindowPane.qml`; são tokens internos de apresentação, não protocolo nem persistência. Para integrar `gamewindow.qml`, faltam contratos de `WorldMap`/`LightMap` e controllers reais; não simular autenticação ou estado do servidor. O schema protobuf de aparências contém grupos de frames, metadados de sprite, animação e caixas direcionais; o leitor do catálogo preserva esses dados no modelo C++. A dependência `liblzma` e um decoder limitado para fluxos LZMA-Alone foram adicionados com testes sintéticos, ainda pendentes de validação externa. Os arquivos `sprites-*.bmp.lzma` do manifesto começam com um prefixo de 24 bytes zero; seu envelope não foi identificado, então o decoder ainda não os consome e nenhum sprite foi renderizado. A instalação `D:\Tibia Global` tem runtimes Qt 6.10.3, diferentes da versão 6.11.1 fixada no projeto; módulos privados não foram encontrados como arquivos soltos e podem estar embutidos no executável, que não foi analisado. Extensões completas de coisas, recursos reais e integração funcional do mapa permanecem pendentes. A Fase 1 foi concluída no ambiente do responsável, com reprodutibilidade em máquina limpa pendente conforme o [registro de aceite](phase1-acceptance.md). O código atual ainda rejeita desafios TOTP como não suportados. Gates de estado de mundo permanecem explícitos.

Foram inspecionados fontes e recursos, verificados catálogo/hashes e produzidos documentos/regras. O resultado de 43/43 cobre apenas o bootstrap headless e seus componentes já implementados; ainda não demonstra compatibilidade operacional completa do novo cliente. Nenhum backend funcional foi encontrado nos recursos e nenhuma limpeza deles é recomendada.

Referências: [auditoria](backend-resource-audit.md), [padrões de código](coding-standards.md), [política de validação](validation-policy.md), [migração de regras](rules-migration.md) e [instruções dos agentes](../.github/copilot-instructions.md).
