import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: storePurchaseSuccessDialog
  caption: qsTrId("store_purchase_success")
  width: 350
  headerDelegate: DialogHeaderDragon {}

  property var controller: null;

  function closeDialog() {
    if (controller != null) {
      controller.requestClose();
    }
  } //function closeDialog()

  onReturnPressedFunction: function() {
    confirmButton.idleState = false;
  }

  onCancelPressedFunction: closeDialog

  initialFocusItem: storePurchaseSuccessDialog
  KeyNavigation.tab: storePurchaseSuccessDialog

  RowLayout {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated

    TibiaTextArea {
      Layout.alignment: Qt.AlignTop
      Layout.fillWidth: true
      Layout.preferredHeight: TibiaStyle.storePurchaseSuccessButtonSize
      text: controller != null ? controller.message : ""

      readOnly: true
      verticalScrollBarPolicy: ScrollBar.AsNeeded
      wrapMode: TextEdit.Wrap
    } //TibiaTextArea

    TibiaButton {
      id: confirmButton
      Layout.alignment: Qt.AlignTop
      Layout.preferredHeight: TibiaStyle.storePurchaseSuccessButtonSize
      Layout.preferredWidth: TibiaStyle.storePurchaseSuccessButtonSize
      color: "blue"
      property bool idleState: true

      onClicked: {
        idleState = false;
      } //onClicked

      Image {
        id: idleAnimation
        anchors.centerIn: parent
        visible: confirmButton.idleState
        SequentialAnimation {
          running: confirmButton.idleState
          loops: Animation.Infinite
          alwaysRunToEnd: false

          ScriptAction { script: SoundHelper.playSound(SoundHelper.STORE_ANIMATION_RATTLING); }
          PropertyAnimation { target: idleAnimation; property: "source"; to: "image://purchasecomplete-idle-animation/0"; duration: 150 }
          PropertyAnimation { target: idleAnimation; property: "source"; to: "image://purchasecomplete-idle-animation/1"; duration: 150 }
          PropertyAnimation { target: idleAnimation; property: "source"; to: "image://purchasecomplete-idle-animation/2"; duration: 150 }
          PropertyAnimation { target: idleAnimation; property: "source"; to: "image://purchasecomplete-idle-animation/3"; duration: 150 }
          PropertyAnimation { target: idleAnimation; property: "source"; to: "image://purchasecomplete-idle-animation/4"; duration: 150 }
          PropertyAnimation { target: idleAnimation; property: "source"; to: "image://purchasecomplete-idle-animation/5"; duration: 150 }

        } //SequentialAnimation
      } //Image

      Image {
        id: pressedAnimation
        anchors.centerIn: parent
        visible: !confirmButton.idleState
        SequentialAnimation {
          running: !confirmButton.idleState
          loops: 1
          alwaysRunToEnd: true

          ScriptAction { script: SoundHelper.playSound(SoundHelper.STORE_ANIMATION_BUY); }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/0"; duration: 0 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/1"; duration: 150 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/2"; duration: 150 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/3"; duration: 150 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/4"; duration: 150 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/5"; duration: 150 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/6"; duration: 150 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/7"; duration: 100 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/8"; duration: 100 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/9"; duration: 100 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/10"; duration: 100 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/11"; duration: 100 }
          PropertyAnimation { target: pressedAnimation; property: "source"; to: "image://purchasecomplete-pressed-animation/12"; duration: 100 }
          ScriptAction { script: closeDialog(); }
        } //SequentialAnimation
      } //Image
    } //TibiaButton
  } //RowLayout
} //TibiaDialog
