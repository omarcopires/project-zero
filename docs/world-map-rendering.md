# Renderização inicial do mapa

O módulo `qmlcomponents` registra `WorldMap` e `LightMap`; `WorldMapItem` desenha objetos estáticos de uma `MapDescription` recebida por injeção. Ele ainda não compõe andares, camadas, padrões, animações, iluminação ou comandos do mapa. `LightMapItem` permanece transparente até receber dados de luz.

O host carrega `clientwindow.qml` e compõe `gamewindow.qml` no `placeholder` original quando a árvore QML está pronta. Os QMLs e as imagens originais em `things/` permanecem inalterados.

O cliente tem adaptadores QML para `AppearanceInstanceRenderer`, `ObjectAppearanceInstance`, `OutfitAppearanceInstance`, `SingleObjectAppearanceInstanceRenderer`, `Lenshelp`, `NumericalEffectOverlay`, `SpeechBubbleOverlay`, `TibiaTargetSelection`, `CachedOutlineText` e `TibiaTutorialMarker`. Os renderers de aparências mostram apenas objetos estáticos de um sprite; Lenshelp, efeitos numéricos, balões, seleção de alvos e marcadores de tutorial preservam a estrutura/contrato necessário, mas ainda não implementam o comportamento privado original. `CachedOutlineText` usa `Text` do Qt Quick sem cache especializado.

`RenderDriver` expõe o backend Qt Quick selecionado. Um provider adicional redimensiona molduras 9-slice de 1 pixel, e a configuração de recursos cria aliases para caminhos literais `/images/...` encontrados nos QMLs quando há arquivo de imagem correspondente na raiz `things/images`. `TibiaEnums` expõe os modos de redimensionamento e antialiasing suportados neste cliente; cache de UI está desativado e o controller de cursor permanece ausente.

`TooltipHelper` fornece descoberta do item-raiz da janela e acompanha movimento, saída e clique do mouse para os tooltips QML. `SoundHelper` expõe os nomes de ações usados pelo QML e elimina as referências indefinidas, mas `playSound` retorna `false`: reprodução permanece indisponível até o cliente adicionar um backend de áudio e resolver o mapeamento dos IDs para o catálogo. A sessão do mundo, seu controller, a seleção de personagens e o resolver de aparências do mapa também continuam pendentes.
