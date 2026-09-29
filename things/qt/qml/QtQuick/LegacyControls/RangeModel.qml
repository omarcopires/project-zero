import QtQuick

Item {
    id: root

    property real minimumValue: 0
    property real maximumValue: 1
    property real value: minimumValue
    property real stepSize: 0
    property bool inverted: false
    property real positionAtMaximum: 0
    property real position: 0
    property bool synchronizing: false

    function boundedValue(candidate) {
        return Math.max(minimumValue, Math.min(maximumValue, candidate));
    }

    function positionForValue(candidate) {
        const range = maximumValue - minimumValue;
        if (range <= 0 || positionAtMaximum <= 0) {
            return 0;
        }
        let ratio = (boundedValue(candidate) - minimumValue) / range;
        if (inverted) {
            ratio = 1 - ratio;
        }
        return ratio * positionAtMaximum;
    }

    function valueForPosition(candidate) {
        if (positionAtMaximum <= 0 || maximumValue <= minimumValue) {
            return minimumValue;
        }
        let ratio = Math.max(0, Math.min(1, candidate / positionAtMaximum));
        if (inverted) {
            ratio = 1 - ratio;
        }
        let nextValue = minimumValue + ratio * (maximumValue - minimumValue);
        if (stepSize > 0) {
            nextValue = minimumValue + Math.round((nextValue - minimumValue) / stepSize) * stepSize;
        }
        return boundedValue(nextValue);
    }

    function synchronizePosition() {
        if (synchronizing) {
            return;
        }
        synchronizing = true;
        value = boundedValue(value);
        position = positionForValue(value);
        synchronizing = false;
    }

    onPositionChanged: {
        if (!synchronizing) {
            synchronizing = true;
            value = valueForPosition(position);
            position = positionForValue(value);
            synchronizing = false;
        }
    }
    onValueChanged: synchronizePosition()
    onMinimumValueChanged: synchronizePosition()
    onMaximumValueChanged: synchronizePosition()
    onStepSizeChanged: synchronizePosition()
    onInvertedChanged: synchronizePosition()
    onPositionAtMaximumChanged: synchronizePosition()
    Component.onCompleted: synchronizePosition()
}
