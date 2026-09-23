import QtQuick
import QtQuick.Layouts




TibiaFrame3PixelFilled {
  id: root
  readonly property int contentStartMargin: borderWidth + 1

  property QtObject controller: null

  width: contextContent.width + 2*contentStartMargin
  height: contextContent.height + 2*contentStartMargin

  ColumnLayout {
    id: contextContent
    anchors {left: parent.left; bottom: parent.bottom}
    anchors.margins: root.contentStartMargin

    spacing: TibiaStyle.entrySpacingVertical

    Repeater {
      id: entryRepeater
      model: controller != null ? controller.entries : undefined

      onCountChanged: {
        if(count == 0) {
          contextContent.width = 0;
        }
      } //onCountChanged

      ColumnLayout {
        spacing: 0

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.bottomMargin: TibiaStyle.entrySpacingVertical
          visible: modelData.isSeparator
        } //TibiaHorizontalSeparator


        Rectangle { //Mouse over highlight
          implicitHeight: 16
          implicitWidth: contextContent.width
          color: mouseArea.containsMouse ? TibiaStyle.contextMenuSelectedBackgroundColor : "transparent"
          visible: !modelData.isSeparator

          MouseArea {
            id: mouseArea
            anchors.fill:parent
            hoverEnabled: true
            onClicked: {
              modelData.toggled(!checkBox.checked);
              modelData.triggered();
            } //onClicked
          } //MouseArea

          RowLayout {
            spacing: 0
            height: parent.height

            onWidthChanged: {
              let newWidth = Math.max(contextContent.width, width);
              if (newWidth != contextContent.width) {
                contextContent.width = newWidth;
              }
            } //onWidthChanged

            //this layout is here to provide the possibility to set width bounds
            RowLayout {
              id: entryContent
              spacing: 0

              Layout.alignment: Qt.AlignVCenter
              Layout.minimumWidth: contextContent.width

              Item { //Spacing entry to left boarder
                Layout.minimumWidth: TibiaStyle.entryPartMargin
                Layout.fillHeight: true
              } //Item

              TibiaCheckBox {
                id: checkBox
                checked: modelData.checked
                visible: modelData.checkable
                onToggled: {
                  modelData.toggled(checked);
                  modelData.triggered();
                } //onClicked
              } //TibiaCheckBox

              TibiaCachedOutlineText {
                id: entryText
                text: modelData.text
                styleType: modelData.styleType
                styleColor: TibiaStyle.contextMenuOutlineColor
              } //TibiaOutlineText

              Item { //spacing entry to shortcut, also extra with
                Layout.minimumWidth: TibiaStyle.minAfterEntrySpace
                Layout.fillWidth: true
                Layout.fillHeight: true
              } //Item

              TibiaCachedOutlineText {
                text:modelData.shortcutString
                styleType: modelData.styleType
                styleColor: TibiaStyle.contextMenuOutlineColor
                visible: text.length > 0
              } //TibiaOutlineText

              Item { //spacing on right side
                Layout.minimumWidth: TibiaStyle.entryPartMargin
                Layout.fillHeight: true
              } //Item
            } //RowLayout
          } //RowLayout
        } //Rectangle
      } //ColumnLayout
    } //Repeater
  } //ColumnLayout
} //TibiaFrame3PixelFilled
