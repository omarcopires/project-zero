import QtQuick
import QtQuick.Layouts




TibiaFrame1PixelDownWithGuiHelp {
  id: root
  Layout.fillWidth: true
  Layout.preferredHeight: showActionBarsLayout.height + 2 * marginsToContent
  guiHelpText: qsTrId("optionsmenu_show_action_bar_help")

  property QtObject optionsSetActionBars: null

  GridLayout {
    id: showActionBarsLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    anchors.margins: parent.marginsToContent
    rowSpacing: TibiaStyle.marginRelated
    columnSpacing: TibiaStyle.marginUnrelated
    columns: 5

    /////////////////////////////////////////////////////
    //BOTTOM ACTION BARS

    TibiaText {
      text: qsTrId("optionsmenu_show_action_bar").arg(qsTrId("bottom"))
    } //TibiaText

    TibiaCheckBox {
      id: showBottomActionBars
      text: qsTrId("all")
      Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showBottomActionBars
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showBottomActionBars = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showBottomActionBar1
      text: qsTrId("optionsmenu_bar").arg(1)
      styleType: showBottomActionBars.checked ? "Dialog" : "Disabled"
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showBottomActionBar1
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showBottomActionBar1 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showBottomActionBar2
      text: qsTrId("optionsmenu_bar").arg(2)
      styleType: showBottomActionBars.checked ? "Dialog" : "Disabled"
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showBottomActionBar2
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showBottomActionBar2 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showBottomActionBar3
      text: qsTrId("optionsmenu_bar").arg(3)
      styleType: showBottomActionBars.checked ? "Dialog" : "Disabled"
      Layout.fillWidth: true
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showBottomActionBar3
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showBottomActionBar3 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    //BOTTOM ACTION BARS
    /////////////////////////////////////////////////////
    //LEFT ACTION BARS

    TibiaText {
      text: qsTrId("optionsmenu_show_action_bar").arg(qsTrId("left"))
    } //TibiaText

    TibiaCheckBox {
      id: showLeftActionBars
      text: qsTrId("all")
      Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showLeftActionBars
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showLeftActionBars = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showLeftActionBar1
      text: qsTrId("optionsmenu_bar").arg(1)
      styleType: showLeftActionBars.checked ? "Dialog" : "Disabled"
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showLeftActionBar1
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showLeftActionBar1 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showLeftActionBar2
      text: qsTrId("optionsmenu_bar").arg(2)
      styleType: showLeftActionBars.checked ? "Dialog" : "Disabled"
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showLeftActionBar2
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showLeftActionBar2 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showLeftActionBar3
      text: qsTrId("optionsmenu_bar").arg(3)
      styleType: showLeftActionBars.checked ? "Dialog" : "Disabled"
      Layout.fillWidth: true
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showLeftActionBar3
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showLeftActionBar3 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    //LEFT ACTION BARS
    /////////////////////////////////////////////////////
    //RIGHT ACTION BARS

    TibiaText {
      text: qsTrId("optionsmenu_show_action_bar").arg(qsTrId("right"))
    } //TibiaText

    TibiaCheckBox {
      id: showRightActionBars
      text: qsTrId("all")
      Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showRightActionBars
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showRightActionBars = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showRightActionBar1
      text: qsTrId("optionsmenu_bar").arg(1)
      styleType: showRightActionBars.checked ? "Dialog" : "Disabled"
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showRightActionBar1
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showRightActionBar1 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showRightActionBar2
      text: qsTrId("optionsmenu_bar").arg(2)
      styleType: showRightActionBars.checked ? "Dialog" : "Disabled"
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showRightActionBar2
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showRightActionBar2 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    TibiaCheckBox {
      id: showRightActionBar3
      text: qsTrId("optionsmenu_bar").arg(3)
      styleType: showRightActionBars.checked ? "Dialog" : "Disabled"
      Layout.fillWidth: true
      shouldBeChecked: optionsSetActionBars!=null && optionsSetActionBars.showRightActionBar3
      onCheckedChanged: {
        if (optionsSetActionBars != null) {
          optionsSetActionBars.showRightActionBar3 = checked;
        }
      } //onCheckedChanged
    } //TibiaCheckBox

    //RIGHT ACTION BARS
    /////////////////////////////////////////////////////

  } //GridLayout
} //TibiaFrame1PixelDownWithGuiHelp
