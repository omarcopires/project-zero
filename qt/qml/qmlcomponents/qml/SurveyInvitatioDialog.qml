import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: surveyInvitationDialog
  caption: qsTrId("survey_invitation_caption")
  width: 410

  property QtObject controller: null

  function yesClicked() {
    if(null != controller) {
      controller.onYesClicked();
    }
  } //function yesClicked()

  function askLaterClicked() {
    if(null != controller) {
      controller.onAskLaterClicked();
    }
  } //function askLaterClicked()

  onReturnPressedFunction: yesClicked
  onCancelPressedFunction: controller!=null ? controller.askLaterClicked : null
  initialFocusItem: surveyInvitationDialog
  KeyNavigation.tab: surveyInvitationDialog

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      spacing: TibiaStyle.marginRelated
      Layout.fillWidth: true

      TibiaText {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: controller!=null ? controller.invitationText : "Dummy Invitation"
      } //TibiaText

      TibiaText {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        property string dateString: controller!=null ? controller.dateString : "some point in the future"
        text: qsTrId("access_survey_from_website_until").arg(dateString)
      } //TibiaText

      TibiaText {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: qsTrId("take_survey_now")
      } //TibiaText
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        text: qsTrId("yes")
        color: "green"
        Layout.preferredWidth: 50

        onClicked: { yesClicked(); }
      } //TibiaButton

      TibiaButton {
        text: qsTrId("no")
        Layout.preferredWidth: 50

        onClicked: controller!=null ? controller.onNoClicked() : undefined
      } //TibiaButton

      TibiaButton {
        text: qsTrId("ask_later")
        visible: controller!=null && controller.showAskLater
        Layout.preferredWidth: 50

        onClicked: { askLaterClicked(); }
       } //TibiaButton
    } //RowLayout

  }//ColumnLayout
} //TibiaDialog
