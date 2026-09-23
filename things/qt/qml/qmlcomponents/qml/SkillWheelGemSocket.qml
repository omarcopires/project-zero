import QtQuick

MouseArea {
  id: socketComponent
  property QtObject socket
  property bool selected

  implicitWidth: 34
  implicitHeight: implicitWidth

  signal socketClicked(gemId: int)

  onClicked: (mouse) => {
    if (socketComponent.socket.gemImageSource) {
      socketClicked(socketComponent.socket.gemId)
    }
  }

  Image {
    source: socketComponent.socket.socketBezelSource != "" ? "/images/skillwheel/backdrop_skillwheel_socket_active.png" : "/images/skillwheel/backdrop_skillwheel_socket_inactive.png"
    anchors.centerIn: parent
    smooth: false
  }

  Image {
    source: socketComponent.socket.gemImageSource
    anchors.centerIn: parent
    smooth: false
  }

  Image {
    source: socketComponent.socket.socketBezelSource
    anchors.centerIn: parent
    smooth: false
  }

  Image {
    source: socketComponent.selected ? "/images/skillwheel/marker_skillwheelsocket.png" : ""
    anchors.centerIn: parent
    smooth: false
  }

} // MouseArea

