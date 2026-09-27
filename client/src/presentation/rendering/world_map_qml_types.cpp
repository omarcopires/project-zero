#include "presentation/rendering/world_map_qml_types.h"

#include "presentation/rendering/light_map_item.h"
#include "presentation/rendering/world_map_item.h"

#include <qqml.h>

namespace client::presentation::rendering {

	void registerWorldMapQmlTypes() {
		qmlRegisterType<WorldMapItem>("qmlcomponents", 1, 0, "WorldMap");
		qmlRegisterType<LightMapItem>("qmlcomponents", 1, 0, "LightMap");
	}

}
