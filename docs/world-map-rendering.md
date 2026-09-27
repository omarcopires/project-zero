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

O host carrega `clientwindow.qml` e agora tenta criar `gamewindow.qml` no
`placeholder` original. A composição só é anexada quando o componente está
pronto e sua criação não registra erros QML; caso contrário, o splash permanece
visível e os erros são gravados em `debug.log`. Isso evita esconder uma
dependência ausente como se a interface estivesse carregada.

A composição ainda depende de tipos que não existem no código C++ nem no módulo
QML deste repositório: `RenderDriver`, `AppearanceInstanceRenderer`,
`ObjectAppearanceInstance`, `OutfitAppearanceInstance` e
`TibiaTargetSelection`. `SingleObjectAppearanceInstanceRenderer` agora tem uma
implementação do cliente que mostra aparências de objeto somente quando o
provider consegue resolver um único sprite estático. Contagem, líquidos,
direção de gancho, decoração e animação ainda não são desenhados por esse
adaptador. Portanto, a integração da tela completa continua condicionada aos
tipos restantes. Ainda falta conectar a sessão do mundo ao mapa e injetar um
resolver de aparências; o controller do mapa permanece pendente. Os QMLs
originais continuam inalterados.
