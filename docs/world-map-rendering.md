# Renderização inicial do mapa

O módulo `qmlcomponents` agora registra tipos C++ para `WorldMap` e `LightMap`,
sem alterar o `qmldir` ou os QMLs originais. `WorldMapItem` aceita uma
`MapDescription` decodificada e uma função de resolução de aparências. Ele
desenha os objetos do andar central em campos de 32 pixels, centrados na
posição inicial; imagens maiores que um campo são ancoradas pela base.

O recorte suporta desenho estático via callback. Ele ainda não compõe
multicamadas, padrões direcionais, animações, outfit colors, andares vizinhos,
iluminação ou comandos do mapa. `LightMapItem` preserva a propriedade `scale`
esperada pelo QML, mas permanece transparente enquanto não há dados de luz.

O renderer está disponível para o host da tela original e inclui testes
sintéticos de registro dos tipos e desenho de um objeto centralizado. Ainda
falta compor `gamewindow.qml`, conectar a sessão do mundo ao item e injetar um
resolver de aparências. O controller do mapa permanece pendente; a tela original
continua sem alterações.
