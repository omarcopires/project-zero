# Renderização inicial do mapa

O módulo `qmlcomponents` registra tipos C++ para `WorldMap` e `LightMap`, sem alterar o `qmldir` ou os QMLs originais. `WorldMapItem` aceita uma `MapDescription` decodificada e uma função de resolução de aparências. Ele desenha objetos do andar central em campos de 32 pixels, centrados na posição inicial; imagens maiores que um campo são ancoradas pela base.

O recorte suporta desenho estático via callback. Ainda não compõe multicamadas, padrões direcionais, animações, cores de outfit, andares vizinhos, iluminação ou comandos do mapa. `LightMapItem` preserva a propriedade `scale` esperada pelo QML, mas permanece transparente enquanto não há dados de luz.

O host carrega `clientwindow.qml` e tenta criar `gamewindow.qml` no `placeholder` original. A composição só é anexada quando o componente está pronto e sua criação não registra erros QML; caso contrário, o splash permanece visível e os erros são gravados em `debug.log`.

O cliente contém adaptadores QML próprios para `AppearanceInstanceRenderer`, `ObjectAppearanceInstance` e `OutfitAppearanceInstance`. O renderer mostra objetos estáticos quando o provider consegue resolver um único sprite; não implementa catálogo de raças, composição em camadas, animação, cores de outfit ou efeitos. `SingleObjectAppearanceInstanceRenderer` também cobre somente um sprite estático, sem contagem, líquidos, direção de gancho ou decoração.

`Lenshelp` mantém as propriedades esperadas pelo QML, mas não mostra o painel de ajuda, pois seu controller nativo não está disponível. `RenderDriver` expõe o backend Qt Quick selecionado, mas não escolhe backend nem implementa o renderer privado original. `TibiaTargetSelection` e a integração da sessão do mundo ao mapa ainda estão pendentes, assim como injetar um resolver de aparências no mapa. Os QMLs originais continuam inalterados.
