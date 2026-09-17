# Auditoria de recursos e vestígios de backend

Data: 2026-09-17. Inspeção estática; nenhuma execução de código do projeto.

## Parecer

Existem **metadados e contratos de integração com o runtime nativo**, além de lógica de apresentação em QML/JavaScript. Não foi localizada uma implementação do núcleo nativo ou do servidor neste workspace nas buscas realizadas. Portanto, a hipótese de vestígios de integração é procedente, mas não justifica classificar pastas como backend descartável.

`qt-project.org/` é um diretório local, não uma consulta à internet. `data/` não é evidência de backend apenas pelo nome.

## Inventário inicial

Contagens obtidas antes de criar documentação e instruções; excluem `.git/`:

| Local | Arquivos | Natureza |
|---|---:|---|
| `data/` | 1 | Componente visual `BlurItem.qml` |
| `images/` | 1.061 | Imagens, fonte, CSS, configurações e dados auxiliares |
| `qt/` | 424 | QMLs da aplicação, controles legados e descritores |
| `qt-project.org/` | 3.018 | Recursos, controles, efeitos e metadados Qt |
| `qtwebchannel/` | 1 | Biblioteca JavaScript de integração |
| `spells/` | 2 | Dados de magias e prévias |
| Raiz | 2 | `.clang-format` e `message.txt` |
| Total | 4.509 | Originais anteriores a esta documentação |

Há 886 arquivos `.qml`, três `.js` e sete `.json` no inventário de recursos. Nem todo QML pertence ao jogo: parte significativa é do framework. `message.txt` também contém QML, relacionado à fusão da Exaltation Forge.

## Evidências por categoria

### Recursos do Qt, não SDK completo

- `qt-project.org/imports/QtCore/qmldir` referencia `Qt6::qtqmlcoreplugin`.
- `qt-project.org/imports/QtWebEngine/qmldir` referencia `qtwebenginequickplugin`.
- `qt-project.org/imports/QML/qmldir` declara metadados como `static`, `system` e `typeinfo`.
- `qt-project.org/styles/`, `qmessagebox/` e `windows/` contêm recursos de estilos, diálogos, cursores e configuração gráfica.

Esses arquivos indicam dependências do runtime Qt 6. Não determinam sua versão exata nem fornecem o SDK completo. Palavras `plugin`, `classname`, `linktarget` e `typeinfo` não são implementações C++ ou DLLs. `optional plugin` não comprova que os tipos nativos sejam dispensáveis.

### Plugins e serviços do jogo referenciados

- `qt/qml/qmlcomponents/qmldir`: `qmlcomponentsplugin`, `qmlcomponents.qmltypes`, imports e caminho `prefer`.
- `qt/qml/qmlcomponents/qml/qmldir`: `qmlguiplugin`, `qmlgui.qmltypes` e registro dos componentes QML presentes.
- `qt/qml/QtQuick/LegacyControls/qmldir`: controles QML e referência ao plugin `Qt5LegacyControls`.
- `qt/qml/qmlcomponents/qml/MapWindowPane.qml`: `WorldMap`, `LightMap`, `mapWindowController` e enums.
- `qt/qml/qmlcomponents/qml/container.qml`: `appearanceTypeListModel` e `AbstractItemModelHelper.wrapInHelperProxyModel`.
- `qt/qml/qmlcomponents/qml/ActionBarButton.qml`: provider `image://action-bar-cooldown/`.

Isso descreve parte do contrato a implementar no motor/adaptador. Não foram localizadas implementações nativas desses tipos. Nomes e métodos observados no QML não comprovam assinaturas C++ originais.

### Lógica real presente, mas de apresentação/integração

- `qtwebchannel/qwebchannel.js` implementa serialização e proxies JavaScript para objetos expostos por um transporte externo. Não implementa, por si só, autenticação ou protocolo de jogo.
- `qt/qml/qmlcomponents/qml/outfitdialog/outfitdialog.js` valida escolhas e altera propriedades de controlador.
- `qt/qml/QtQuick/LegacyControls/calendarutils.js` fornece utilitários de calendário.
- Há GLSL embutido em QML de efeitos, por exemplo `qt-project.org/imports/Qt5Compat/GraphicalEffects/private/GaussianDirectionalBlur.qml`. A ausência de arquivos de shader separados não significa ausência de código gráfico.

### Dados não equivalem a regras autoritativas do servidor

- `spells/spells.json`: catálogo com IDs, custos, vocações, cooldowns e descrições.
- `spells/spells-previews.json`: sequências temporais de efeitos visuais.
- `images/ImportantBalancingMessageData.json`: conteúdo para mensagem de balanceamento.
- `images/vocation-selection-dialog-data.json`: exemplos de magias/equipamentos para apresentação.
- `images/tutorial-catalog.json`: referencia dump e hints do tutorial.
- `images/tutorial-sessiondump.dmp` e `.hints`: presença e referências verificadas; conteúdo não aberto nem interpretado nesta auditoria.
- `images/clientoptions.json`: arquivo auxiliar existente; não é evidência de configuração de build ou servidor.

## Ausências observadas e limites

Não foram encontrados, nos padrões pesquisados, fontes `.cpp`, `.h`, `.hpp`, `.c`, `.cc`, `.cxx`; binários `.dll`, `.exe`, `.so`, `.dylib`, `.lib`, `.a`; metadados `.qmltypes`; manifestos `.qrc`/`.rcc`; ou projetos CMake/qmake/Visual Studio. Também não foram localizados pacotes usuais `.spr`/`.dat` de aparências do cliente nem catálogo completo de sprites de mundo.

Isso não é prova de ausência no histórico Git, em arquivos ignorados/compactados ou em instalações externas, que não foram auditados. O código do servidor examinado anteriormente em `E:\caverot-server` é externo a este repositório e não deve ser confundido com o conteúdo de `project-zero`.

## Mapeamentos de recursos que exigem atenção

1. `clientwindow.qml` importa `qrc:/qt/qml/qmlcomponents/qml`; diretórios físicos não substituem automaticamente o registro desse caminho.
2. Descritores `prefer :/...` podem selecionar recursos embutidos. Preservar o disco não demonstra qual conteúdo o runtime carrega.
3. `TibiaFrame1PixelDown.qml` referencia `/images/grid/1pixel-down-frame-top.png`, enquanto o recurso encontrado está em `images/1pixel-down-frame-top.png`.
4. `images/Verdana10px.fnt` aponta para `/fonts/Verdana10px.png`, mas a imagem física está em `images/Verdana10px.png`.
5. O catálogo do tutorial usa `qrc:/tutorial/...` para arquivos fisicamente em `images/`.
6. Providers `image://...` exigem implementação, não apenas aliases para arquivos.

A solução deverá usar manifestos/aliases e registro de serviços em arquivos novos, sem mover ou editar os originais. Aliases não podem apontar para cópias modificadas que contornem o contrato.

## Consequências para o plano

- Manter todas as árvores originais, inclusive recursos de terceiros e arquivos ainda não compreendidos.
- Inventariar tipos, propriedades, métodos, sinais, roles, image providers e recursos antes de integrar uma tela.
- Corrigir incompatibilidades no motor novo; não converter QML para OTUI nem simplificar componentes existentes.
- Confirmar sprites, metadados, traduções, Qt e licenças como requisitos próprios; a disponibilidade de uma interface não resolve essas dependências.
- A inspeção não demonstra capacidade de execução, fidelidade de renderização ou compatibilidade 15.25.

Durante a tarefa documental foram registrados hashes SHA-256 de 4.509 arquivos originais, incluindo `.clang-format`, para comparação final. A comparação limita-se ao intervalo da tarefa; não certifica a procedência anterior nem impede alterações futuras. Build, testes e execução do cliente/servidor não fazem parte desta auditoria.
