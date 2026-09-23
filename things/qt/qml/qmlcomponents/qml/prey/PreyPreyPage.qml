import QtQuick
import QtQuick.Layouts

import qmlcomponents

import "qrc:/qt/qml/qmlcomponents/qml"

ColumnLayout {
  id: preyDialog
//  width: preyViewsLayout.width + 2*TibiaStyle.dialogMarginBorder

  property var controller: null
  property var preyList: null

  onControllerChanged: {
    preyList = null;
    if (controller != null) {
      preyList = controller.preyList;
    }
  }

  onPreyListChanged: slotsWrapper.recreateSlots();


  KeyNavigation.tab: preyDialog
  KeyNavigation.backtab: preyDialog

  ColumnLayout {
    id: preyViewsLayout
    Layout.fillWidth: true
    spacing: TibiaStyle.marginRelated

    RowLayout {
      spacing: TibiaStyle.marginUnrelated

    RowLayout {
        id: slotsWrapper
        spacing: 0
        Layout.fillWidth: true

        Component {
          id: singlePreyViewComponent
          SinglePreyView {
            property var modelData: null

            clientSettingSmoothFiltering: controller != null && controller.clientSettingSmoothFiltering
            listRerollPrice: controller != null ? controller.listRerollPrice : "?"
            listRerollTooExpensive: controller != null && controller.listRerollTooExpensive
            bonusRerollPrice: controller != null && controller.bonusRerollPrice
            bonusRerollTooExpensive: controller != null && controller.bonusRerollTooExpensive
            choosePreyPrice: controller != null && controller.choosePreyPrice
            choosePreyTooExpensive: controller != null && controller.choosePreyTooExpensive

            onHoverTextChanged: {
              displayHoverText.text = hoverText;
            } //onHoverTextChanged


            Component.onCompleted: { delayAllowHoverMouse.start(); }
            Timer {
              id: delayAllowHoverMouse
              interval: 0
              onTriggered: { allowHoverMouse = true; }
            } //Timer

          }
        }
        Component {
          id: spaceComponent
          Item {
            Layout.fillWidth: true
          }
        }

        function recreateSlots() {

          for(var i = children.length; i > 0 ; i--) {
            children[i-1].destroy()
          }
          if (preyList != null) {
            for (var i = 0; i < preyList.length; i++) {
              var slotData = preyList[i]
              if (i != 0) {
                var newSpacer = spaceComponent.createObject(slotsWrapper);
              }
              var newSlot = singlePreyViewComponent.createObject(slotsWrapper);
              newSlot.preyViewModel = slotData;
            }
          }
        }
      }
    } //RowLayout

    TibiaFrame2PixelUpFilled {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.bottomMargin: TibiaStyle.marginRelated
      
      TibiaText {
        id: displayHoverText
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: TibiaStyle.marginNarrow + parent.borderWidth

        wrapMode: Text.Wrap
        textFormat: Text.RichText
      } //TibiaText
    } //TibiaFrame2PixelUpFilled
  }

} // TibiaDialog
