import QtQuick
import QtQuick.Layouts

FocusScope {
  id: root
  implicitWidth: 100
  implicitHeight: textField.implicitHeight

  property alias bottomPadding: textField.bottomPadding
  property alias horizontalAlignment: textField.horizontalAlignment
  property alias maximumLength: textField.maximumLength
  property alias text: textField.text
  property alias validator: textField.validator
  property alias updateDelay: filterRefreshTimer.interval
  property string intText: ""
  readonly property int intValue: parseInt(intText)
  property real minimumValue: 0
  property real maximumValue: 100

  signal escPressedInTextField()

  property string shouldBeText: ""
  onShouldBeTextChanged: {
    if (   textField.text.length > 0
        || Number(shouldBeText) > root.minimumValue
        || textField.activeFocus == false) {
      textField.shouldBeText = shouldBeText;
    }
    root.intText = shouldBeText;
  } //onShouldBeTextChanged

  TibiaFrame1PixelDown {
    id: visualRoot
    anchors.fill:  parent

    RowLayout {
      anchors.fill: parent
      spacing: 0

      TibiaTextField {
        id: textField
        Layout.fillWidth: true
        Layout.fillHeight: true
        KeyNavigation.tab: root.KeyNavigation.tab
        KeyNavigation.backtab: root.KeyNavigation.backtab
        maximumLength: TibiaStyle.maxTextFieldDefaultLength
        focus: true

        validator: IntValidator {
          bottom: root.minimumValue
          top: root.maximumValue
          locale: "en_GB"
        } //validator: IntValidator

        onTextChanged: {
          filterRefreshTimer.restart();
        } //onTextChanged

        Keys.onPressed: (event) => {
          if (focus && event.key == Qt.Key_Escape) {
            root.escPressedInTextField()
            // Intentionally do not accept event to propagate further up
          }
        } //Keys.onPressed

        Timer {
          id: filterRefreshTimer
          interval: TibiaStyle.searchDelay

          onTriggered: {
            var numericValue = Number(text);
            if (!isNaN(numericValue)) {

              if (numericValue < root.minimumValue) {
                numericValue = root.minimumValue;
              }
              if (numericValue > root.maximumValue) {
                numericValue = root.maximumValue;
              }
             
              if (   root.intValue != numericValue
                  || root.intValue != textField.text) {
                root.intText = numericValue;
                if (textField.text.length > 0 ) {
                  textField.text = numericValue;
                }
              }
            }
          } //onTriggered
        } //Timer

        onActiveFocusChanged: {
          if (activeFocus) {
            selectAll();
          } else {
            textField.text = root.intText;
          }
        } //onActiveFocusChanged
      } //TibiaTextField
    } //RowLayout
  } //TibiaFrame1PixelDown
} //FocusScope
