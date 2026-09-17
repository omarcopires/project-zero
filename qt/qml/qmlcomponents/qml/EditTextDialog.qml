import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: editTextDialog
  caption: controller != null ? controller.modelData.dialogCaption : qsTrId("edit_text_caption")
  width: 313

  property var controller: null

  onReturnPressedFunction: function() { if (confirmButton.visible) confirmButton.clicked() }

  onCancelPressedFunction: function() { cancelButton.clicked() }

  initialFocusItem: editTextArea

  ColumnLayout {
    height: 400
    width: parent.width
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      id: mainLayout
      spacing: TibiaStyle.marginUnrelated

      RowLayout {
        spacing: TibiaStyle.marginUnrelated
        visible: descriptionText.text.length > 0

        Image {
          source: "/images/edit-list-logo.png"
          visible: !appearanceInstanceViewer.visible
        } //Image

        SingleObjectAppearanceInstanceRenderer {
          id: appearanceInstanceViewer
          Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField
          Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField

          animated: true
          typeid: controller != null ? controller.modelData.objectID : 0
          cumulativeCount: controller != null ? controller.modelData.objectCount :0
          liquidType: controller != null ? controller.modelData.liquidType : ObjectAppearanceInstance.EMPTY
          hookDirection: controller != null ? controller.modelData.hookDirection : ObjectAppearanceInstance.NONE
        } //SingleObjectAppearanceInstanceRenderer

        TibiaText {
          id: descriptionText
          text: controller != null ? controller.modelData.editDescription : ""
          Layout.fillWidth: true
          wrapMode: Text.Wrap
        } //TibiaText
      } // RowLayout

      RowLayout {
        id: phishingWarning
        spacing: TibiaStyle.marginUnrelated
        visible: controller != null && controller.modelData.showPhishingWarning

        Image {
          source: "/images/skin/classic/warning-triangle.png"
        } //Image

        TibiaText {
          Layout.fillWidth: true
          styleType: "MessageCritical"
          text: qsTrId("edit_phishing_warning")
          wrapMode: Text.Wrap
        } //TibiaText
      } //RowLayout

      RowLayout {
        id: recentlyTradedWarning
        spacing: TibiaStyle.marginUnrelated
        visible: controller != null && controller.modelData.showRecentlyTradedWarning

        Item {
          Layout.preferredHeight: 32
          Layout.preferredWidth: 32
          Image {
            anchors.centerIn: parent
            source: "/images/skin/classic/show-gui-help-orange.png"
          } //Image
        } //Item


        TibiaText {
          Layout.fillWidth: true
          styleType: "MessageWarning"
          text: qsTrId("edit_recently_traded_warning")
          wrapMode: Text.Wrap
        } //TibiaText
      } //RowLayout

      TibiaTextArea {
        id: editTextArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        text: controller != null ? controller.modelData.editText : ""
        readOnly: controller != null ? !controller.modelData.textIsEditable : false
        maximumLength: controller != null ? controller.modelData.maximumEditTextLength : -1
        wrapMode: TextEdit.Wrap
        KeyNavigation.tab: editTextArea

        onActiveFocusChanged: {
          if (focus && !readOnly && !cursorMovedToEnd) {
            scrollToEndTimer.start();
          } else if (readOnly) {
            editTextArea.cursorPosition = 0;
          }
        } //onActiveFocusChanged

        Timer {
          id: scrollToEndTimer
          interval: 0
          repeat: false
          onTriggered: editTextArea.pushCursorToEnd()
        } //Timer

        property bool cursorMovedToEnd: false
        function pushCursorToEnd() {
          editTextArea.cursorPosition = editTextArea.length;
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
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad

          text: qsTrId("context_report_text")
          visible: controller != null && controller.modelData.showReportButton

          onClicked: {
            if (controller != null) {
              controller.reportText();
            }
          } //onClicked
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } //Item

        TibiaButton {
          id: confirmButton
          text: qsTrId("ok")
          visible: controller != null ? controller.modelData.textIsEditable : true

          onClicked: {
            if (controller != null) {
              controller.submitNewText(editTextArea.text);
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          id: cancelButton
          text: confirmButton.visible ? qsTrId("cancel") : qsTrId("ok")

          onClicked: {
            if (controller != null) {
              controller.abortEditing();
            }
          } //onClicked
        } // TibiaButton
      } // RowLayout
    } // ColumnLayout
  } // Item
} // TibiaDialog
