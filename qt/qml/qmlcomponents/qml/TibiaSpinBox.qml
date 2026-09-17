import QtQuick
import QtQuick.Layouts
import QtQml

import qmlcomponents

RowLayout {
    spacing: 0
    property alias initialValue: valueFied.shouldBeText
    property alias minValue: valueFied.minimumValue
    property alias maxValue: valueFied.maximumValue
    property alias currentValue: valueFied.intValue

    TibiaButton {
        implicitWidth: 20
        imageSource: "/images/icon-arrowskiptoend.png"
        imageSourceDisabled: "/images/icon-arrowskiptoend-disabled.png"
        enabled: parseInt(valueFied.text) > valueFied.minimumValue
        onClicked: valueFied.text = valueFied.minimumValue
    } //TibiaButton

    TibiaButton {
        implicitWidth: 20
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        enabled: parseInt(valueFied.text) > valueFied.minimumValue
        onClicked: {
            if (valueFied.intValue > valueFied.minimumValue)
                valueFied.text = valueFied.intValue - 1;
        }
        autoRepeat: true
    } //TibiaButton

    TibiaIntField {
        id: valueFied

        horizontalAlignment: Qt.AlignRight
        implicitWidth: 50
        implicitHeight: button.height
        shouldBeText: "0"
        updateDelay: 0
    } //TibiaIntField

    TibiaButton {
        id: button
        implicitWidth: 20
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        imageMirrored: true
        enabled: parseInt(valueFied.text) < valueFied.maximumValue
        onClicked: {
            if (valueFied.intValue < valueFied.maximumValue)
                valueFied.text = valueFied.intValue + 1;
        }
        autoRepeat: true
    } //TibiaButton

    TibiaButton {
        implicitWidth: 20
        imageSource: "/images/icon-arrowskiptoend.png"
        imageSourceDisabled: "/images/icon-arrowskiptoend-disabled.png"
        imageMirrored: true
        enabled: parseInt(valueFied.text) < valueFied.maximumValue
        onClicked: valueFied.text = valueFied.maximumValue
    } //TibiaButton
}
