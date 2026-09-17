import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents


Item {
  id: combatControlsRoot

  property var panelController: null
  property bool expertModeEnabled: false
  property bool exportModeButtonEnable: panelController != null && panelController.exportModeButtonEnable

  implicitWidth: TibiaStyle.sideBarPanelRightSideWith
  implicitHeight: playerControls.height

  states: [
    State {
      name: ""
      PropertyChanges { target: combatControlsRoot; implicitWidth: TibiaStyle.sideBarPanelRightSideWith }
    },
    State {
      name: "MINIMIZED"
      PropertyChanges { target: combatControlsRoot; implicitWidth: 112 }
    }
  ]

  GridLayout {
    id: playerControls
    anchors {left: parent.left; top: parent.top; right: parent.right}

    columns: 1
    rowSpacing: 6
    columnSpacing: 0

    state: parent.state

    states: [
      State {
        name: ""
        PropertyChanges {
          target: playerControls
          width: pvpControls.width
        }
        PropertyChanges {
          target: buttonExpert
          visible: true
        }
        PropertyChanges {
          target: buttonSecureMode
          visible: true
        }
      },

      State {
        name: "MINIMIZED"
        PropertyChanges {
          target: playerControls
          columns: -1
          rows: 1
        }
        PropertyChanges {
          target: combatControls
          columns: 3
          rows: -1
          columnSpacing: 0
          flow: GridLayout.LeftToRight
        }
        PropertyChanges {
          target: buttonExpert
          visible: false
        }
        PropertyChanges {
          target: smallButtonSecureMode
          visible: true
        }
        PropertyChanges {
          target: fillItem
          visible: true
          Layout.fillWidth: true
        }
        PropertyChanges {
          target: buttonSecureMode
          visible: false
        }
      }
    ] // states

    GridLayout {
      id: combatControls
      rows: 3
      columnSpacing: 2
      rowSpacing: 3
      flow: GridLayout.TopToBottom

      ButtonGroup {
        id: chaseModeGroup
      } // ButtonGroup

      TibiaIconButton {
        id: buttonStand
        sourceUp: "/images/button-stand-up.png"
        sourceDown: "/images/button-stand-down.png"
        tooltipText: qsTrId("combatpanel_stand_still")
        ButtonGroup.group: chaseModeGroup
        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: panelController != null && !panelController.chaseEnabled

        onClicked: {
          if (panelController != null) { panelController.onChaseModeChangeRequested(false); }
        } //onClicked
      } //TibiaIconButton

      TibiaIconButton {
        id: buttonFollow
        sourceUp: "/images/button-follow-up.png"
        sourceDown: "/images/button-follow-down.png"
        tooltipText: qsTrId("combatpanel_chase_opponent")
        ButtonGroup.group: chaseModeGroup
        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: panelController != null && panelController.chaseEnabled

        onClicked: {
          if (panelController != null) { panelController.onChaseModeChangeRequested(true); }
        } //onClicked
      } //TibiaIconButton

      TibiaIconButton {
        id: buttonExpert
        sourceUp: enabled ? "/images/button-expert-up.png" : "/images/button-expert-disabled.png";
        sourceDown: enabled ? "/images/button-expert-down.png" : "/images/button-expert-disabled.png";
        tooltipText: qsTrId("combatpanel_expert_mode");

        enabled: exportModeButtonEnable
        onEnabledChanged: {
          expertModeEnabled = false;
        } //onEnabledChanged

        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: expertModeEnabled

        onClicked: {
          expertModeEnabled = !expertModeEnabled;
        } //onClicked

        onCheckedChanged: {
          if (!checked && panelController != null) { panelController.onPvPModeDoveRequested(); }
        } //onCheckedChanged
      } //TibiaIconButton

      TibiaButton {
        id: smallButtonSecureMode
        Layout.preferredHeight: TibiaStyle.buttonHeightDefault
        Layout.preferredWidth: Layout.preferredHeight
        imageSourceUp: "/images/icon-secure-mode.png"
        imageSourceDown: "/images/icon-normal-mode.png"
        tooltipText: qsTrId("combatpanel_secure_mode_on")
        tooltipTextChecked: qsTrId("combatpanel_secure_mode_off")
        visible: false
        checkable: true

        buttonShouldBeChecked: panelController != null && !panelController.secureModeEnabled
        useButtonShouldBeChecked: true

        onClicked: {
          if (panelController != null) { panelController.onSecureModeEnabledRequested(!panelController.secureModeEnabled); }
        } //onClicked
      } //TibiaIconButton

    } // GridLayout (Combat controls)

    TibiaButton {
      id: buttonSecureMode
      Layout.bottomMargin: 1
      Layout.fillWidth: true
      imageSourceUp: "/images/icon-secure-mode.png"
      imageSourceDown: "/images/icon-normal-mode.png"
      text: qsTrId("pvp")
      tooltipText: qsTrId("combatpanel_secure_mode_on")
      tooltipTextChecked: qsTrId("combatpanel_secure_mode_off")
      checkable: true

      textXOffset: -7
      imageXOffset: 10

      buttonShouldBeChecked: panelController != null && !panelController.secureModeEnabled
      useButtonShouldBeChecked: true

      onClicked: {
        if (panelController != null) { panelController.onSecureModeEnabledRequested(!panelController.secureModeEnabled); }
      } //onClicked

      Lenshelp {
        anchors.fill: parent
        caption: qsTrId("combatpanel_secure_mode_lenshelp_caption")
        content: qsTrId("combatpanel_secure_mode_lenshelp")
      } //Lenshelp
    } //TibiaIconButton

    Item {
      id: fillItem
      Layout.fillWidth: false
      visible: false
    } //Item

    GridLayout {
      id: pvpControls
      rows: 2
      columns: 2
      columnSpacing: 2
      rowSpacing: 3
      flow: GridLayout.TopToBottom
      visible: buttonExpert.checked

      ButtonGroup {
        id: pvpModeGroup
      } // ButtonGroup

      TibiaIconButton {
        id: buttonDoveMode
        sourceUp: "/images/button-combat-dovemode-up.png"
        sourceDown: "/images/button-combat-dovemode-down.png"
        tooltipText: qsTrId("combatpanel_dove_mode")
        ButtonGroup.group: pvpModeGroup
        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: panelController != null && panelController.pvpModeDove

        onClicked: {
          if (panelController != null) { panelController.onPvPModeDoveRequested(); }
        } //onClicked
      } //TibiaIconButton

      TibiaIconButton {
        id: buttonYellowHand
        sourceUp: "/images/button-combat-yellowhandmode-up.png"
        sourceDown: "/images/button-combat-yellowhandmode-down.png"
        tooltipText: qsTrId("combatpanel_yellowhand_mode")
        ButtonGroup.group: pvpModeGroup
        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: panelController != null && panelController.pvpModeYellowHand

        onClicked: {
          if (panelController != null) { panelController.onPvPModeYellowHandRequested(); }
        } //onClicked
      } //TibiaIconButton

      TibiaIconButton {
        id: buttonWhiteHand
        sourceUp: "/images/button-combat-whitehandmode-up.png"
        sourceDown: "/images/button-combat-whitehandmode-down.png"
        tooltipText: qsTrId("combatpanel_whitehand_mode")
        ButtonGroup.group: pvpModeGroup
        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: panelController != null && panelController.pvpModeWhiteHand

        onClicked: {
          if (panelController != null) { panelController.onPvPModeWhiteHandRequested(); }
        } //onClicked
      } //TibiaIconButton

      TibiaIconButton {
        id: buttonRedFist
        sourceUp: "/images/button-combat-redfistmode-up.png"
        sourceDown: "/images/button-combat-redfistmode-down.png"
        tooltipText: qsTrId("combatpanel_redfist_mode")
        ButtonGroup.group: pvpModeGroup
        checkable: true
        useButtonShouldBeChecked: true

        buttonShouldBeChecked: panelController != null && panelController.pvpModeRedFist

        onClicked: {
          if (panelController != null) { panelController.onPvPModeRedFistRequested(); }
        } //onClicked
      } //TibiaIconButton
    } // GridLayout (PvP controls)
  } // GridLayout

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // LENSHELP and TOOLTIPS
  //as visibility is controlled by de c++ controller set size to 0 to hide the lenshelp trigger

  Lenshelp {
    x: combatControls.x
    y: combatControls.y
    width: combatControls.visible ? combatControls.width : 0
    height: combatControls.visible ? combatControls.height : 0
    caption: qsTrId("combatpanel_tactics_lenshelp_caption")
    content: qsTrId("combatpanel_tactics_lenshelp")
  } //Lenshelp

  Lenshelp {
    //need to be defined after lenshelp for combatControls to overlay it
    x: buttonExpert.x
    y: buttonExpert.y
    width: buttonExpert.visible ? buttonExpert.width : 0
    height: buttonExpert.visible ? buttonExpert.height : 0
    caption: qsTrId("combatpanel_expert_mode_lenshelp_caption")
    content: qsTrId("combatpanel_expert_mode_lenshelp")
  } //Lenshelp

  Lenshelp {
    //need to be defined after lenshelp for combatControls to overlay it
    x: smallButtonSecureMode.x
    y: smallButtonSecureMode.y
    width: smallButtonSecureMode.visible ? smallButtonSecureMode.width : 0
    height: smallButtonSecureMode.visible ? smallButtonSecureMode.height : 0
    caption: qsTrId("combatpanel_secure_mode_lenshelp_caption")
    content: qsTrId("combatpanel_secure_mode_lenshelp")
  } //Lenshelp

  Lenshelp {
    x: pvpControls.x
    y: pvpControls.y
    width: pvpControls.visible ? pvpControls.width : 0
    height: pvpControls.visible ? pvpControls.height : 0
    caption: qsTrId("combatpanel_pvp_controls_lenshelp_caption")
    content: qsTrId("combatpanel_pvp_controls_lenshelp")
  } //Lenshelp
} //Item
