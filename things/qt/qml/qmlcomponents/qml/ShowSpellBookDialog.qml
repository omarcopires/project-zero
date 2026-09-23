import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: showSpellBookDialog
  caption: qsTrId("spell_book_dialog_caption")
  width: 313

  property var controller: null

  onReturnPressedFunction: function() { if (confirmButton.visible) confirmButton.clicked() }
  onCancelPressedFunction: function() { if (confirmButton.visible) confirmButton.clicked() }
  

  ColumnLayout {
    height: 400
    width: parent.width
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      id: mainLayout
      spacing: TibiaStyle.marginUnrelated

      RowLayout {
        spacing: TibiaStyle.marginUnrelated
        
        SingleObjectAppearanceInstanceRenderer {
          id: appearanceInstanceViewer
          Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField
          Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField

          animated: true
          typeid: (controller != null && controller.spellBookID != 0) ? controller.spellBookID :  3059
          cumulativeCount: 0
        } //SingleObjectAppearanceInstanceRenderer

        TibiaText {
          id: descriptionText
          text: qsTrId("spell_book_dialog_icon_text")
          Layout.fillWidth: true
          wrapMode: Text.Wrap
        } //TibiaText
      } // RowLayout

      TibiaTextArea {
        id: textArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        text: controller != null ? controller.spellBookText : ""
        readOnly: true
        wrapMode: TextEdit.Wrap
        KeyNavigation.tab: textArea

        onActiveFocusChanged: {
          if (focus && !readOnly && !cursorMovedToEnd) {
            scrollToEndTimer.start();
          } else if (readOnly) {
            textArea.cursorPosition = 0;
          }
        } //onActiveFocusChanged

        Timer {
          id: scrollToEndTimer
          interval: 0
          repeat: false
          onTriggered: textArea.pushCursorToEnd()
        } //Timer

        property bool cursorMovedToEnd: false
        function pushCursorToEnd() {
          textArea.cursorPosition = textArea.length;
          cursorMovedToEnd = true;
        } //function pushCursorToEnd()
      } // TibiaTextArea
    } // ColumnLayout

    ColumnLayout {
      id: bottomMenuBar
      Layout.alignment: Qt.AlignBottom
      spacing: TibiaStyle.marginUnrelated

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      } //TibiaHorizontalSeparator

      RowLayout {
        spacing: TibiaStyle.marginRelated

        TibiaButton {
          Layout.preferredWidth: 100

          text: qsTrId("spell_book_open_magical_archive")

          onClicked: {
            if (controller != null) {
              controller.openCyclopedia();
            }
          } //onClicked
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } //Item

        TibiaButton {
          id: confirmButton
          text: qsTrId("ok")
          
          onClicked: {
            if (controller != null) {
              controller.requestClose();
            }
          } //onClicked
        } // TibiaButton

      } // RowLayout
    } // ColumnLayout
  } // Item
} // TibiaDialog
