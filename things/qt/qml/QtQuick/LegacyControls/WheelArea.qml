import QtQuick

Item {
    id: root

    property real horizontalMinimumValue: 0
    property real horizontalMaximumValue: 0
    property real horizontalValue: 0
    property real horizontalDelta: 0
    property real verticalMinimumValue: 0
    property real verticalMaximumValue: 0
    property real verticalValue: 0
    property real verticalDelta: 0
    property real scrollSpeed: 20
    readonly property bool active: wheelArea.containsMouse

    MouseArea {
        id: wheelArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true

        onWheel: function(wheel) {
            const horizontalSteps = wheel.pixelDelta.x !== 0
                ? wheel.pixelDelta.x
                : wheel.angleDelta.x / 120 * root.scrollSpeed;
            const verticalSteps = wheel.pixelDelta.y !== 0
                ? wheel.pixelDelta.y
                : wheel.angleDelta.y / 120 * root.scrollSpeed;

            root.horizontalDelta = -horizontalSteps;
            root.verticalDelta = -verticalSteps;

            const nextHorizontalValue = Math.max(
                root.horizontalMinimumValue,
                Math.min(root.horizontalMaximumValue, root.horizontalValue + root.horizontalDelta)
            );
            const nextVerticalValue = Math.max(
                root.verticalMinimumValue,
                Math.min(root.verticalMaximumValue, root.verticalValue + root.verticalDelta)
            );

            if (nextHorizontalValue !== root.horizontalValue || nextVerticalValue !== root.verticalValue) {
                root.horizontalValue = nextHorizontalValue;
                root.verticalValue = nextVerticalValue;
                wheel.accepted = true;
            }
        }
    }
}
