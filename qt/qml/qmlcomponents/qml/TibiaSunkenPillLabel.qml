import QtQuick
import QtQuick.Layouts
import QtQml

import qmlcomponents

BorderImage {
    property alias text: text.text

    source: "/images/bossdifficultysel/bds_player_box.png"
    smooth: false
    horizontalTileMode: BorderImage.Repeat
    border { left: 7; top: 7; right: 7; bottom: 7 }

    TibiaText {
        id: text

        horizontalAlignment: Text.AlignHCenter
        width: parent.width - 2 * TibiaStyle.marginUnrelated
        anchors.centerIn: parent
    }
}
