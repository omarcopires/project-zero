import QtQuick



Image {
  id: skullBackground
  source: "/images/skin/classic/unjustified-points-skull-dent.png"

  property alias skullImageSource: skull.source

  Image {
    id: skull
    anchors.centerIn: parent
    source: "" 
  } //Image
} //Image
