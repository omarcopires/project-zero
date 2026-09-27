# Provider de imagens de aparências

O adaptador Qt Quick `AppearanceImageProvider` liga o catálogo Protobuf de
aparências ao loader das folhas CIP. O identificador de imagem tem o formato
`image://appearance/<tipo>/<id>`, com tipo `object`, `outfit`, `effect` ou
`missile`.

O processo recebe o caminho explícito do diretório de assets pela variável
`CLIENT_ASSETS_DIRECTORY`. Esse diretório deve conter
`catalog-content.json`, o arquivo de aparências e as folhas de sprites
referenciadas pelo catálogo. Quando a variável estiver ausente ou o catálogo
não puder ser carregado, as solicitações retornam imagem vazia.

Este incremento desenha somente uma aparência estática composta por uma camada,
um padrão em cada dimensão e um único sprite, sem animação. Aparências animadas,
multicamada ou com padrões adicionais ficam sem imagem até que composição e
sincronização de frames sejam implementadas. O provider não modifica nem
substitui QML original.

O `clientwindow.qml` atualmente carregado não solicita imagens deste provider.
Ele estabelece o adaptador e o caminho de consumo para integração posterior; a
tela de jogo ainda depende dos tipos e controllers nativos `WorldMap`,
`LightMap` e `mapWindowController`.
