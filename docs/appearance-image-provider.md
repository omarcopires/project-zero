# Appearance image provider

The Qt Quick `AppearanceImageProvider` connects the protobuf appearance catalog to the CIP sprite-sheet loader. URLs have the form `image://appearance/<type>/<id>`, where the type is `object`, `outfit`, `effect`, or `missile`.

Set `CLIENT_ASSETS_DIRECTORY` to a directory containing `catalog-content.json`, the referenced appearance file, and CIP sprite sheets. Requests return an empty image if the variable is absent or the catalog cannot be loaded.

The provider currently renders only a static appearance with one layer, one pattern in each dimension, and one sprite. Animated or multilayer appearances and additional patterns return no image until composition and frame synchronization exist. It does not modify or replace the original QML. The originally loaded `clientwindow.qml` does not request this provider directly; world presentation also depends on `WorldMap`, `LightMap`, and `mapWindowController`.
