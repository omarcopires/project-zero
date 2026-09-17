# Fase 0 — Contratos, decisões e ressalvas

Data: 2026-09-17. Estado: **entrega documental concluída com ressalvas; aceite técnico não declarado**. Nenhuma implementação iniciada. O [termo de encerramento](phase0-acceptance.md) e a [verificação de assets](phase0-assets-verification.md) consolidam as confirmações finais e os gates restantes. Complementa o [plano-base](project-plan-2026-09-17.md) e a [auditoria de recursos](backend-resource-audit.md).

## Decisões desta rodada

- O responsável selecionou **Qt 6 pelo vcpkg** como origem única e aprovou a proposta em 2026-09-17. Após o inventário local, determinou usar as ferramentas modernas disponíveis **sem modificar seu ambiente**: Visual Studio 2026 e MSVC 14.51.36231 substituem a recomendação anterior de MSVC 2022/v143. Mantêm-se C++20, Qt 6.11.1, baseline fixo, ports/features descritos, `x64-windows` dinâmico e Qt Network. Não misturar com SDK Qt externo. Aprovação da seleção não equivale a compatibilidade ou validação executável.
- Preservar a instalação do Visual Studio, `D:\vcpkg`, SDKs, PATH e variáveis do ambiente. Não instalar toolset antigo, atualizar ou trocar o checkout compartilhado, executar bootstrap nem instalar dependências. Preferir ferramentas modernas não significa seguir `latest`/`master` móveis ou habilitar recursos experimentais automaticamente; registrar versões explícitas para reprodução.
- O responsável esclareceu que `E:\caverot-client` é seu cliente, modificado e mantido por ele ao longo dos anos. Ele é a **referência funcional e de contratos** desta etapa; não é necessário indicar outra URL. Isso não implica adoção do motor antigo: Clean Architecture e nomes sem marca continuam obrigatórios.
- O projeto novo é **fechado, com acesso restrito ao responsável**. Uma eventual abertura ou publicação será decidida por ele no futuro, fora do escopo atual. O frontend protegido permanece integralmente preservado.
- O responsável confirmou que o cliente local compila com as alterações C++ atuais, apresenta seleção de personagens e permite login e jogo normal no servidor 15.25, sem problemas relevantes observados. É **validação manual relatada pelo responsável**, não execução do agente nem garantia de ausência de defeitos. Na confirmação final, ele associou os executáveis às últimas modificações; HEADs reconferidos, sem atestação criptográfica fonte/binário.
- O responsável autorizou continuidade automática das etapas e commits das entregas revisadas, respeitando todas as restrições. A progressão deve parar quando depender de informação ou ação sua; não há autorização para push ou execução de projetos.

## Confirmação do laboratório — 2026-09-17

- O responsável confirmou que ambos os projetos de referência estão compilados na última versão. O relato associa o funcionamento aos fontes atuais segundo o responsável; não constitui identificação criptográfica dos binários nem nova medição Git. As revisões observadas abaixo permanecem evidências da inspeção, sem atribuição automática aos executáveis.
- Modo confirmado: autenticação por **sessão**, com **e-mail e senha**. O servidor possui 2FA, mas sua implementação no novo cliente foi adiada pelo responsável para depois do incremento inicial. O canal do segundo fator não foi confirmado.
- Endpoint de login confirmado: `http://127.0.0.1:8080/api/v1/webservice`. O `init.lua` fornecido pelo responsável declara esse valor em `loadConfig().webservice` e atribui a configuração a `Services`. O arquivo externo não foi alterado.
- Houve uma tentativa GET indevida nesta rodada, fora do escopo documental, sem credenciais, redirects ou leitura de corpo. Resultado: `ConnectFailure`, sem resposta HTTP. Não houve repetição nem tentativa de autenticação. O resultado não valida a rota POST, o login por sessão ou a disponibilidade em outro momento; não contradiz o relato funcional do responsável. Não repetir sondagens para suprir pendências.
- HTTP sem TLS permanece restrito ao laboratório em loopback. Na confirmação final, o responsável informou servidor em `localhost`, login TCP 7171 e mundo 15.25 TCP 7172. O destino de laboratório é `localhost:7172`; não assumir a porta 8080 para jogo nem criar fallback do fluxo HTTP para login TCP.
- Adiar 2FA não significa desativar proteção no servidor: se uma tentativa exigir desafio, o incremento inicial deve informar fluxo não suportado e não prosseguir como autenticado. Não contornar o desafio, reutilizar sessão indevidamente ou simular sucesso. Uma futura validação sem 2FA depende de conta de laboratório para a qual o serviço não exija desafio, sem fornecer credenciais ao agente.

## Revisões e limites da evidência

| Base | Revisão HEAD observada | Estado dos arquivos examinados |
|---|---|---|
| Servidor externo | `c7c8337842da610ff7c6569235d781c9276b7287` | Git sem mudanças locais nos sete fontes enumerados abaixo |
| Cliente candidato externo | `02e0ae82693cbb7036983329d03246157947a751` | Git sem mudanças locais em `CMakeLists.txt` e `vcpkg.json`; logger já verificado na rodada anterior |
| Frontend local | Base original preservada nos commits até `6e2f6b9` | Inspeção de consumidores QML, não de implementação nativa |

Os sete fontes do servidor são `src/core.hpp`, `src/server/network/protocol/protocol_profile.cpp`, `src/server/network/protocol/protocolgame.cpp`, `src/server/network/http/routes.cpp`, `src/server/network/http/webservice/webservice.cpp`, `src/server/network/http/webservice/handlers/login_handler.cpp` e `src/io/iologindata.cpp`. Estado limpo desses caminhos não certifica toda a árvore nem o binário utilizado pelo responsável.

Não foram consultados remotes, chaves, bancos, logs reais, dumps ou artefatos de build. A configuração de serviços em `init.lua` foi fornecida explicitamente pelo responsável; não houve leitura adicional de configurações ativas para inferir segredos ou destinos. Houve consultas públicas à documentação Qt e aos metadados vcpkg. A tentativa GET sem conexão estabelecida está registrada acima; não houve execução de código de projeto, configuração, build, instalação ou testes executáveis. Linhas indicadas são localizadores da revisão inspecionada, não contratos estáveis de localização.

## Contrato estático do servidor 15.25

Caminhos relativos a `E:\caverot-server`:

| Aspecto | Evidência de fonte | Consequência / pendência |
|---|---|---|
| Identidade | `src/core.hpp:15–18` declara release 3.6.1 e `CLIENT_VERSION = 1525` | Não comprova identidade do executável em uso |
| Perfil Current | `protocol_profile.cpp:193–205,435–452`, sob `src/server/network/protocol/` | Seleção Current por igualdade com a versão atual; perfis legados existentes ficam fora do novo cliente |
| Capacidades | `protocolgame.cpp:104–131` no mesmo diretório | A lista detalhada de proficiência depende da capacidade e de build reconhecida dentro de 15.25; número de versão isolado é insuficiente. Rastreamento completo dos pontos de uso permanece pendente |
| Estado inicial de conexão | `protocolgame.cpp:88–98,645–685,1181–1230` | Classificação da porta e perfil influenciam a negociação inicial; nenhuma porta efetiva ou receita de mensagens é presumida |
| Autenticação HTTP | `src/server/network/http/routes.cpp:8–11` e `webservice/webservice.cpp:14–30` | Existe rota POST de webservice com despacho de login. Existência de fonte não comprova serviço habilitado nem transporte seguro |
| Estados de autenticação | `webservice/handlers/login_handler.cpp:136–258`, relativo ao diretório HTTP | Credenciais, limitação de tentativas e estados de segundo fator/dispositivo confiável; resposta recebida não equivale a sucesso |
| Mundos e personagens | Mesmo handler, `:156–177,260–303` | Destino vem da configuração; personagens não excluídos pertencem à conta. Campos de apresentação com placeholders não comprovam suporte funcional |
| Sessão | Mesmo handler, `:305–344` | Emissão opaca com persistência de hash e expiração calculada; falha impede sucesso. Revogação e renovação ainda precisam de análise própria |
| Entrada no mundo | `protocolgame.cpp:1420–1439` e `src/io/iologindata.cpp:24–66` | Validação de sessão/conta/personagem depende do modo de autenticação. Lista recebida e seleção local não confirmam ingresso |

O fluxo **HTTP → sessão → jogo TCP** está identificado nos fontes do cliente e do servidor. O responsável confirmou seleção, login e jogo normais, executáveis nas últimas modificações, sessão, endpoint HTTP e mundo em `localhost:7172`. Os HEADs foram reconferidos sem mudança; o relato não é atestação criptográfica dos binários. HTTP sem TLS fica restrito ao laboratório loopback; não sondar serviços nem enviar mensagens por suposição. Nenhum material sensível deve ser anexado como evidência.

## Fluxo do cliente funcional — inspeção estática

Caminhos relativos a `E:\caverot-client`, HEAD `02e0ae82693cbb7036983329d03246157947a751`. A consulta Git dos 28 fontes examinados no rastreamento não apontou alterações locais. Isso não vincula automaticamente o executável relatado a esse commit.

| Etapa | Fontes / localizadores | Contrato observado |
|---|---|---|
| Autenticação | `packages/client_entergame/entergame.lua:270–520,720–865`; `packages/gamelib/webservice.lua:1–20` | `EnterGame.doLogin` usa URL de webservice; `doLoginHttp` inicia autenticação HTTP/JSON. Resultado distingue transporte, autenticação e estados adicionais |
| Transporte HTTP | `packages/corelib/http.lua:45–59,204–233`; `src/framework/http/http.cpp:75–111` | Operações identificadas por ID; trabalho HTTP e entrega de resultados pelo dispatcher. Não levar globais Lua ao núcleo novo |
| Sessão e lista | `entergame.lua:270–350`; `packages/client_entergame/classes/world.lua:120–149` | `session` e `playdata` fornecem sessão, personagens e mundos; associação por identificador de mundo. Host anunciado pode sofrer override/proxy, cuja configuração ativa não foi consultada |
| Seleção | `packages/client_entergame/characterlist.lua:680–765,1078–1114,1250–1450`; `classes/login.lua:36–163` no mesmo diretório | Seleção gera tentativa via `LoginEvent`; chama `g_game.loginWorld`. Retorno indica início da tentativa, não ingresso confirmado |
| Conexão ao mundo | `src/client/game.cpp:565–587`; `src/client/protocolgame.cpp:11–48`; `src/framework/net/connection.cpp:13–87,158–184` | Criação de jogador/protocolo, impedimento de login concorrente e conexão TCP assíncrona |
| Confirmação e mapa | `src/client/protocolgameparse.cpp:420–427,663–712,971–1000`; `src/client/game.cpp:185–231` | Login aceito, estado pendente, entrada e primeiro mapa são eventos distintos. `onGameStart` não garante mapa completo |
| Erro e cancelamento | `characterlist.lua:150–350,587–610`; `classes/login.lua:170–204`; `src/client/game.cpp:149–180,233–284,614–641` | Erros de autenticação/rede, espera e cancelamento são tratados separadamente; encerramento limpa estado e eventos |
| Versão | `src/definitions.h:5`; `src/client/game.cpp:1835–1870`; `packages/game_features/features.lua:1–114` | Constante C++ 1525 e funcionalidades modernas explícitas. A origem da versão Lua e inicialização anterior dos setters no ramo `session/playdata` não ficaram fechadas neste recorte |

### Limites e requisitos derivados

- Domínio/casos de uso novos devem distinguir autenticação, lista disponível, conexão ao mundo, entrada confirmada e mapa disponível, com ownership e cancelamento explícitos. Globais `G`, `g_game` e arquitetura Lua são evidência da referência, não desenho a copiar.
- O ramo examinado de cancelamento HTTP não demonstrou cancelamento da operação ou invalidação da resposta tardia. O backend novo precisa definir isso e escrever testes determinísticos; não se trata de defeito reproduzido na referência.
- `src/framework/http/session.cpp:24–32` desabilita verificação de certificado no ramo HTTPS examinado. **Não reproduzir essa configuração**: HTTPS no backend novo deve verificar cadeia de confiança e identidade do servidor. O funcionamento relatado não comprova segurança desse transporte.
- Inicialização de versão, retomada completa da fila de espera e revogação/renovação de sessão continuam sem fechamento neste recorte. O destino de laboratório foi confirmado pelo responsável como `localhost:7172`; overrides/proxy não foram verificados. Não foi aberta configuração ativa para suprir essas lacunas.
- Nenhum pacote binário, implementação ou conteúdo sensível foi copiado. A observação de contratos e o relato funcional não comprovam compatibilidade do frontend QML deste workspace.

## Inventário inicial de contratos QML

Recorte parcial: composição, login e seleção de personagem; mapa/chat/contêiner apenas para planejar o MVP. Caminhos abaixo relativos a `qt/qml/qmlcomponents/qml/`. Chamadas e acessos QML não comprovam assinaturas, tipos de retorno ou sinais C++ originais.

O [inventário de recursos da composição inicial e seleção](phase0-initial-resource-contracts.md) detalha sete referências literais de imagens, dois aliases premium necessários, URLs dinâmicas, fontes, traduções e ownership de modelos/aparências. Correspondentes físicos foram identificados para as sete imagens; registro de recursos, sprites e compatibilidade executável continuam pendentes. Esse fechamento parcial não encerra a Fase 0.

| Consumidor | Contrato observado | Obrigação do adaptador / bloqueio |
|---|---|---|
| `clientwindow.qml:1–6,35–58,113–121` | Import `qrc:/qt/qml/qmlcomponents/qml`, `windowTitle`, `windowTitleExtension`, `backgroundImageVisible`, item `placeholder` | Mapeamento externo e composição ainda necessários; presença de filho é critério visual, não estado de sessão |
| `gamewindow.qml:40–112,139–165,466–543` | `controller.loginPressed(email, password)`, `gameWindowState`, `isAuthenticated`; limpeza de senha após comando | Injetar controller e definir estados/erros/cancelamento sem alterar consumidores; não inferir endpoint a partir do QML |
| `gamewindow.qml:582–727` | `rememberEmail`, `showEmailAsPlainText`, `initialLoginEmail`, recuperação de conta e preferências | Respeitar acessos de leitura/escrita; persistência e ações externas ainda não especificadas |
| `CharacterSelection.qml:12–47,135–175,425–454` | `required property QtObject controller`, `characterList`, confirmação com array de índices, busca, ordenação, `lastSelectedIndex`, cancelamento | Modelo precisa atender `length` e contratos da tabela; não presumir que qualquer `QAbstractItemModel` baste |
| `CharacterSelection.qml:204–406` | Colunas `outfit`, `characterName`, `dailyRewardState`, `level`, `vocation`, `world`; dados adicionais `isPinned`, `isMainCharacter`, `isHidden`, `worldRules` | Preservar colunas e distinguir roles declaradas de acessos a `modelData`; mapeamento do servidor ainda incompleto |
| `CharacterSelection.qml:14–19,472–574` | Estado premium, filtros, `premiumFeaturesModel`, ações de conta; aparência com cores/addons | Componentes fora do MVP podem continuar sendo dependências de criação. Não simular sucesso para ocultar ausência |
| `OutfitAppearanceInstanceRenderer.qml:6–82` | Tipos `AppearanceInstanceRenderer`, `OutfitAppearanceInstance`, `ObjectAppearanceInstance`, enum e lista de instâncias | Tipos nativos, metadados e sprites autorizados são dependências já na seleção |
| `MapWindowPane.qml:25–43,188–197,219–229,306–341` | `WorldMap`, `LightMap`, `mapWindowController`, sinais de clique/drag/alvo e composição de iluminação | Contrato de eventos, estado sincronizado e renderização Qt Quick ainda por definir |
| `Chat.qml:14–34,123–211` e `ChatOutput.qml:28–41,92–104,199–287` | Modelos de canais/abas, medição de fonte/largura, seleção de texto e `sendKeyword` | Não são listas passivas; lifecycle e semântica de seleção exigem contrato próprio |
| `container.qml:20–40,164–234` | `appearanceTypeListModel`, helper proxy, `length`, `rowCount()`, `sourceItemDataByRowIndex`, notificações e slots | Preservar nomes legados, inclusive `liquideType`; não substituir por modelo simplificado incompatível |

### Dependências transitivas e bloqueios

- Os `qmldir` de `qmlcomponents`, `qmlcomponents.qml` e `QtQuick.LegacyControls` declaram plugins, typeinfo e caminhos preferenciais de recursos. A ausência de implementações/metadados nativos já auditada não é resolvida apenas selecionando Qt 6 no vcpkg.
- `gamewindow.qml` importa `qmlenumvalues`; o inventário não localizou implementação correspondente. Também compõe mapa, chat, barras e `RenderDriver` antes de haver evidência de uma sessão. Invisibilidade não elimina dependências de criação.
- `TibiaTableView.qml:8–27` deriva de `TableViewOld` e acessa `__listView`; trocar controles por versões modernas sem preservar contrato não é solução permitida.
- `TibiaDialog.qml`, `TibiaTextField.qml` e transitivas exigem controllers de cursor, menu e cópia. Comentários de injeção de controller não demonstram a implementação ausente.
- A instanciação de `CharacterSelection` e a entrega de seu controller não ficaram demonstradas na busca focada. `dialogPlaceholder` não comprova sozinho o ciclo de vida.
- O [inventário de autenticação visual](phase0-authentication-ui-contracts.md) localizou `TwoFactorEMailTextEnterDialog.qml`, com entrada textual, confirmação, cancelamento e ação associada ao reenvio por e-mail. Sua criação e ligação ao login não foram demonstradas, nem a correspondência com o segundo fator efetivo do servidor. Diálogo existente não comprova fluxo completo; não criar frontend substituto.
- **Inconsistência estática confirmada:** `Chat.qml:585–586` chama `chatInput.deslect()`, enquanto `ChatInput.qml:29–31` declara `deselect()`. O impacto não foi executado. Não há solução compatível demonstrada exclusivamente nos adaptadores permitidos. A implementação do caminho afetado fica bloqueada; não editar QML, injetar remendo de runtime nem substituir o componente para corrigir a grafia.
- A inspeção transitiva posterior identificou `image://optimized1pixelborderimage/` em `Optimized1PixelBorderImage.qml`, consumido pelos botões; aliases não implementam esse provider. Também foram identificados `WheelArea` nos controles legados e dependências privadas dos efeitos. Ver [termo de encerramento](phase0-acceptance.md). Imports `qrc:`, URLs dinâmicas e aliases continuam pendentes de inventário completo.

## Matriz inicial de compatibilidade

Nenhuma fixture foi criada. Critérios abaixo são futuros, para responsável/CI; não autorizam execução pelo agente.

| Funcionalidade | Evidência no servidor | Referência cliente | Fixture planejada | Contrato QML | Critério de aceite externo |
|---|---|---|---|---|---|
| Login / segundo fator | Handler HTTP e estados identificados | Fluxo HTTP/JSON rastreado; segundo fator não confirmado manualmente | Respostas sintéticas sem credenciais, sucesso/erro/segundo fator | `gamewindow` e diálogo de segundo fator por e-mail mapeados; orquestração e correspondência do canal pendentes | Estados distintos, cancelamento e falha sem exposição de segredos |
| Lista e seleção | `playdata`, mundos/personagens e validação conta-personagem | Associação personagem–mundo rastreada; seleção funcional relatada | Lista sintética, ordenação e seleção inválida | `CharacterSelection`, tabela legada e aparências | Índices/roles coerentes; selecionar não antecipa ingresso |
| Sessão / ingresso | Sessão emitida e autenticação de jogo separadas | Eventos distintos identificados; login/jogo funcionais relatados, sem vínculo exato fonte/binário | Eventos sintéticos de transição/expiração/erro | Estado do controller e composição ainda parciais | Entrada confirmada pelo servidor e limpeza na desconexão |
| Mapa / movimento | Não detalhado nesta rodada | Não avaliada | Estado de mundo sintético com atualização/correção | `MapWindowPane`, `WorldMap`, `LightMap` | Estado real e coordenadas/DPI coerentes |
| Chat | Não detalhado nesta rodada | Não avaliada | Mensagens e seleção sintéticas | `Chat`/`ChatOutput`; caminho com grafia divergente bloqueado | Sincronização e seleção corretas, sem contornar originais |
| Inventário | Não detalhado nesta rodada | Não avaliada | Itens/slots/notificações sintéticos | `container`, helper e roles legadas | Atualizações confirmadas e notificações coerentes |
| Combate básico | Capacidades de proficiência parcialmente identificadas, não contrato de combate | Não avaliada | Eventos sintéticos de alvo/estado | Evento de seleção de alvo; demais consumidores pendentes | Estado autoritativo coerente entre clientes de laboratório |

## Referência, recursos e toolchain

### Candidato local

O `CMakeLists.txt` examinado declara CMake mínimo 3.22, C++20 e dependências gráficas diferentes de Qt. O `vcpkg.json` inclui spdlog e baseline `9e593bb18ea69cc5095e012465dcd675a822ed0d`. Esses valores são **evidência do candidato, não escolhas do projeto novo**; não copiar manifesto, nomes, runtime ou arquitetura.

O responsável confirmou que mantém esse cliente ao longo dos anos. A revisão observada fica registrada como referência para comparar contratos, sem importar sua arquitetura para o núcleo novo.

### Qt pelo vcpkg

- Origem, versão Qt e baseline selecionados pela aprovação da proposta abaixo; resolução e compatibilidade ainda não validadas.
- Levantar cobertura de Qt Quick, QML, Controls, Layouts, Qt5Compat/GraphicalEffects e módulos transitivos declarados nos descritores, sem presumir equivalência para `LegacyControls` ou plugins do jogo.
- Avaliar separadamente módulos presentes no pacote e módulos realmente exigidos pelo recorte; presença de descritores WebEngine/WebChannel não prova que sejam necessários no bootstrap headless.
- Fixar C++, MSVC, CMake, triplet e vinculação/runtime coerentes com Qt e dependências. Preservar `.clang-format`. Definir versão de spdlog por baseline e reproduzir o [contrato de logging](coding-standards.md#contrato-obrigatório-do-backend-novo).
- A consulta de disponibilidade no PATH não encontrou `cmake`, `cl`, `vcpkg`, `qmake` ou `qtpaths` na sessão inspecionada. Isso **não comprova ausência de instalações** fora desse ambiente. Nenhuma ferramenta foi executada para obter versão.

### Seleção de toolchain — proposta aprovada

Consulta estática e aprovação do responsável em 2026-09-17. A combinação abaixo foi aprovada para adoção; **não declara dependências instaladas, resolução executada ou compatibilidade comprovada**. Os termos candidato/recomendação nas tabelas preservam a distinção entre seleção e validação técnica. Nenhum manifesto, preset ou código foi criado. A consulta pública de metadados não envolveu conexão ao servidor do jogo.

| Decisão | Recomendação | Fundamentação / limite |
|---|---|---|
| Padrão C++ | C++20 por alvo, sem extensões do compilador | Suficiente como base inicial; também atende ao requisito de linguagem publicado para WebEngine. Não herdar C++23 do servidor nem usar modo `latest` |
| Origem Qt | Exclusivamente vcpkg | Decisão já confirmada pelo responsável |
| Revisão vcpkg candidata | `fa8cecf91d7f31a1715a7a6524f208897ffb33ce` | Manifests, baseline e triplet consultados nessa revisão imutável; não usar `master` móvel no projeto |
| Qt candidato | 6.11.1 | Versões dos ports e do baseline conferidas; adequação aos recursos privados do frontend ainda não demonstrada |
| Plataforma/triplet | Windows x64, `x64-windows` | Triplet declara bibliotecas e CRT dinâmicos; WebEngine dessa revisão exige Windows x64 e `!static` |
| Compilador | Visual Studio Community 2026, MSVC 14.51.36231 | Seleção explícita do responsável após inventário; não exigir MSVC 2022/v143. A matriz Qt 6.11 consultada lista MSVC 2022, portanto não comprova suporte a esta combinação |
| CMake | 4.3.1-msvc1 fornecido pelo Visual Studio | Versão lida nos metadados do arquivo, sem execução; compatibilidade com ports ainda não validada |
| Gerador | Ninja fornecido pelo Visual Studio, Debug/Release separados | Executável localizado; metadados de versão vazios. Não substituir nem baixar outro Ninja |
| Windows SDK | 10.0.26100.0 disponível localmente | Diretório de headers identificado; não comprova completude da instalação ou sucesso de build |
| Transporte | Qt Network no adaptador; `QCoreApplication` na composição | Evita uma segunda biblioteca de I/O; domínio/casos de uso permanecem sem Qt, sockets ou spdlog |
| Testes | GoogleTest no núcleo; Qt Test na integração de adaptadores | Execução exclusivamente pelo responsável/CI; Qt Quick Test somente na integração visual posterior |
| Renderização | Adiar seleção do backend gráfico até mapear `RenderDriver` e tipos nativos | Não inferir OpenGL, D3D ou compatibilidade a partir dos imports |

#### Ports, features e separação por fase

Versões abaixo incluem a revisão do port com sufixo `#N` quando diferente de zero. Para os ports declarados diretamente, a proposta é desabilitar features padrão e habilitar explicitamente as listadas. Isso **não elimina dependências/features transitivas**; o grafo final precisa ser conferido pelo responsável/CI na futura resolução.

| Fase / finalidade | Port e versão no baseline | Features explícitas propostas |
|---|---|---|
| Diagnóstico sem interface e transporte | `qtbase` 6.11.1#2 | `network`, `thread`, `openssl`; `testlib` para testes dos adaptadores |
| Logging de infraestrutura | `spdlog` 1.17.0#1 | `fmt`, `tz-offset`; sem benchmark. Manter o [contrato de logging](coding-standards.md#contrato-obrigatório-do-backend-novo) |
| Testes puros | `gtest` 1.18.0 | Nenhuma feature adicional |
| Integração visual posterior | `qtbase` 6.11.1#2 | Acrescentar `gui`, `opengl`, `png`, `jpeg`, `freetype`, `harfbuzz`; `windeployqt` no empacotamento. Suporte OpenGL não decide o backend do renderizador |
| QML, Quick, Controls e módulos relacionados | `qtdeclarative` 6.11.1 | Nenhuma feature própria nesse manifest; inclui dependências como `qtshadertools`, `qtsvg` e `qtlanguageserver` |
| Efeitos legados do frontend | `qt5compat` 6.11.1 | `qml`, para os imports de GraphicalEffects; não fornece o módulo local `QtQuick.LegacyControls` |
| Integração web quando o recorte carregado exigir | `qtwebengine` 6.11.1#2 | `webengine`, `webchannel`; `webengine` também exige `pdf` transitivamente nesse port |
| Tipos QML de WebChannel | `qtwebchannel` 6.11.1 | `qml`; também solicitado transitivamente por `qtwebengine[webchannel]` |

O bootstrap da Fase 1 é **sem QML e sem janela**. Não precisa de Quick, Controls, GraphicalEffects ou WebEngine para carregar uma UI, pois não carrega UI alguma. Isso não garante que o grafo transitivo de dependências seja mínimo. A futura integração gráfica constitui outro recorte e não pode dispensar imports necessários apenas porque uma tela está invisível.

HTTPS deve validar certificado e identidade do servidor; selecionar `openssl` não comprova instalação do backend TLS nem configuração de confiança. Não desabilitar validações para obter funcionamento aparente.

#### Evidências do frontend e risco de versão

Exemplos de arquivos efetivamente inspecionados, relativos à raiz; não são inventário completo de propriedades ou prova de carregamento:

| Consumidor | Import / consequência |
|---|---|
| `qt/qml/qmlcomponents/qml/clientwindow.qml` | `QtQuick`, `QtQml`, `QtQuick.Window`, `Qt5Compat.GraphicalEffects`; raiz `Window`, portanto gráfica |
| `qt/qml/qmlcomponents/qml/TibiaButton.qml` e `TibiaCheckBox.qml` | `QtQuick.Templates` e `QtQuick.Controls.Basic` |
| `qt/qml/qmlcomponents/qml/ConfiguredBossSlot.qml` | `QtQuick.Effects` |
| `qt/qml/qmlcomponents/qml/createaccountandcharacter/CreateAccountDialog.qml` | Imports reais de `QtWebEngine` e `QtWebChannel`, além de `QtQuick.LegacyControls` |
| `qt/qml/qmlcomponents/qml/textureatlasviewer.qml` | `QtCore` |
| `qt-project.org/imports/QtQuick/Dialogs/quickimpl/qml/FileDialog.qml` | `QtQuick.Dialogs.quickimpl`, `QtQuick.Controls.Basic.impl`, `Qt.labs.folderlistmodel` |
| `qt-project.org/imports/QtQuick/Controls/Basic/TableViewDelegate.qml` e `SelectionRectangle.qml` | `Qt.labs.qmlmodels` e `QtQuick.Shapes` |
| `qt-project.org/imports/QtQuick/Controls/Windows/CheckBox.qml` | `QtQuick.NativeStyle` |
| `qt-project.org/imports/Qt5Compat/GraphicalEffects/Blend.qml` | `Qt5Compat.GraphicalEffects.private` |
| `data/BlurItem.qml` e `message.txt` | QtQuick; o segundo também importa Layouts e `qmlcomponents`. Extensão `.txt` não prova ausência de QML nem uso em runtime |

Os recursos embutidos também importam `QtQuick.Controls.impl` e implementações específicas de estilos, inclusive FluentWinUI3. **APIs privadas e plugins podem variar entre versões Qt**; os arquivos preservados não identificam sozinhos um SDK compatível. Imports opcionais de estilos nos `qmldir` não tornam todos esses estilos dependências diretas do recorte Windows.

`qmlcomponents`, `qmlcomponents.qml`, `qmlenumvalues` e `QtQuick.LegacyControls` são contratos locais a atender no motor/adaptadores novos. Nomes de plugins e instruções `prefer` dos descritores devem ser respeitados externamente, não apagados ou substituídos nos originais. Imports por URL `qrc:` e arquivos JavaScript locais não são ports vcpkg independentes. `import QtQuick.Layouts 1.2` em `TibiaDialog.qml` não identifica a versão do SDK nem comprova erro isoladamente.

Se a avaliação externa demonstrar incompatibilidade de Qt 6.11.1 com esses contratos, reavaliar a versão candidata ou a adaptação permitida; **não atualizar, remendar ou substituir os recursos protegidos para encaixar no SDK**. A escolha mais recente disponível não é automaticamente a escolha compatível.

#### Ambiente existente — inventário estático

Inventário realizado em 2026-09-17 com consulta ao instalador por `vswhere`, metadados de arquivos, diretórios, registro do SDK e leitura Git/JSON. Não foram executados compiladores, CMake, Ninja, vcpkg ou scripts do projeto.

| Item | Evidência local |
|---|---|
| Visual Studio | Community 2026, instalação `18.10.12210.168`, marcada completa pelo instalador, em `D:\Microsoft Visual Studio\18\Community` |
| MSVC | Diretório `VC\Tools\MSVC\14.51.36231` nessa instalação; nenhum v143 encontrado no recorte consultado |
| CMake | `Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe`, relativo ao Visual Studio; metadados `4.3.1-msvc1` |
| Ninja | `Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe`, relativo ao Visual Studio; versão não identificada pelos metadados |
| Windows SDK | Raiz registrada `D:\Windows Kits\10\`, diretório `Include\10.0.26100.0` |
| vcpkg | `D:\vcpkg\vcpkg.exe` presente; HEAD local `127402f1c75bb3d5ff6bce04b285faa4930a5aca` |
| Baseline local | `qtbase` 6.11.1#1, diferente de 6.11.1#2 no baseline selecionado; os outros seis ports da tabela têm as mesmas versões/revisões. Nenhuma mudança Git nos dois caminhos consultados: `versions/baseline.json` e `triplets/x64-windows.cmake` |
| PATH da sessão | `vcpkg`, `cmake`, `ninja` e `cl` não localizados; isso não invalida os arquivos encontrados nem autoriza alterar o PATH |

O baseline selecionado `fa8cecf91d7f31a1715a7a6524f208897ffb33ce` continua sendo a referência documental das dependências. Ele não é o HEAD local e não foi aplicado a `D:\vcpkg`. Um futuro manifesto pode especificar baseline distinto do checkout, mas disponibilidade dos objetos Git e resolução não foram verificadas; não executar fetch, checkout ou instalação para suprir essa lacuna. Nenhum pacote instalado foi inventariado ou presumido a partir do baseline.

#### Pendências técnicas após aprovação

- Avaliar externamente Qt/ports com MSVC 14.51.36231 e CMake 4.3.1-msvc1. Ausência dessa combinação na matriz consultada não prova incompatibilidade, mas também não permite declarar suporte verificado. Não voltar automaticamente a v143 nem exigir mudança do ambiente.
- A documentação WebEngine consultada exige compilador C++20 e SDK pelo menos `10.0.26100.0`; os mínimos publicados para VS 2022 não certificam VS 2026. C++20 permanece o padrão aprovado, independentemente da versão mais nova do compilador.
- Registrar a versão do Ninja e verificar disponibilidade das ferramentas host e do baseline na futura validação pelo responsável/CI. Se algo faltar, registrar o bloqueio sem instalar ou alterar o ambiente.
- Validar externamente resolução, ABI, plugins, TLS e empacotamento. Integração QML e fidelidade visual permanecem validações posteriores, sem aceite presumido. A seleção aprovada não autoriza agentes a configurar, compilar ou executar projetos.

Fontes públicas consultadas: [baseline fixo](https://github.com/microsoft/vcpkg/blob/fa8cecf91d7f31a1715a7a6524f208897ffb33ce/versions/baseline.json), [ports nessa revisão](https://github.com/microsoft/vcpkg/tree/fa8cecf91d7f31a1715a7a6524f208897ffb33ce/ports), [triplet](https://github.com/microsoft/vcpkg/blob/fa8cecf91d7f31a1715a7a6524f208897ffb33ce/triplets/x64-windows.cmake), [Qt para Windows](https://doc.qt.io/qt-6/windows.html) e [requisitos WebEngine](https://doc.qt.io/qt-6/qtwebengine-platform-notes.html). As páginas Qt são móveis; os requisitos relatados correspondem à consulta desta rodada.

## Encerramento documental e gates técnicos

O responsável solicitou finalizar a etapa e confirmou os dados restantes do laboratório. A entrega documental da Fase 0 está concluída com ressalvas, conforme [termo](phase0-acceptance.md); não equivale a compatibilidade comprovada ou inventário global completo.

1. Laboratório: sessão, e-mail/senha, API HTTP, `localhost:7172` e executáveis nas últimas modificações confirmados por relato. HEADs reconferidos. Não repetir pedidos do resultado funcional geral; hashes de binários não foram medidos. 2FA continua proteção do servidor, com implementação adiada e falha explícita no incremento que não o suporta.
2. Toolchain: seleção fixada, mas validação externa pendente para o aceite da Fase 1. Consulta local não resolveu o objeto Git do baseline selecionado; não houve fetch ou modificação do ambiente. Versão Ninja, resolução, ABI e build permanecem por validar pelo responsável/CI.
3. Recursos: todas as 5.090 referências do catálogo existem. Aparências locais e do servidor diferem em tamanho/hash; correspondência semântica é gate da Fase 3. Traduções não localizadas; arquivos Verdana encontrados no Windows, sem prova de métricas/empacotamento. Ver [auditoria dos assets](phase0-assets-verification.md).
4. Contratos: formato exato deve ser rastreado antes do enquadramento da Fase 1 e antes de cada mensagem nas fases seguintes. Completar APIs transitivas antes da integração visual da Fase 4. Manter caminho afetado do chat bloqueado na Fase 5 sem solução compatível demonstrada.

**Próxima etapa:** bootstrap sem interface da [Fase 1](phase1-bootstrap-transport.md), ainda não iniciado. O fechamento documental não dispensa os gates de cada incremento e nunca autoriza agentes a configurar, compilar ou executar projetos.
