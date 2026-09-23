import QtQuick
import QtQuick.Layouts

import qmlcomponents

TibiaSidebarWidget {
  id: root
  caption: qsTrId("playerguidewidget_caption")
  picSource: "/images/skin/classic/icon-playerguide-widget.png"

  minContentHeight: 200

  TibiaScrollView {
    id: scrollView
    anchors.fill: parent

    Flickable {
      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds

      contentHeight: {
        if (!widgetController) return 0
        if (widgetController.isShowLevelUp) return levelContentLayout.height
        if (widgetController.isShowLevelSpecialPopup) return levelSpecialPopupContentLayout.height
        return playerGuideContentLayout.height
      }
      contentWidth: parent.availableWidth

      // Level Up notification
      ColumnLayout {
        id: levelContentLayout
        visible: widgetController && widgetController.isShowLevelUp
        anchors {
          left: parent.left; right: parent.right
        }
        spacing: TibiaStyle.marginUnrelated

        onVisibleChanged: {
          if (visible) {
            highlightFlashRepeated()
          }
        }

        // Level Up image
        Image {
          source: "/images/playerguide/playerguide-icon-levelup.png"

          Layout.alignment: Qt.AlignHCenter
          smooth: false

          // center the image if there are no spells to show
          Layout.topMargin: widgetController && widgetController.isShowAutoSpellList
            ? TibiaStyle.marginWide
            : (scrollView.height / 2 - implicitHeight / 2)

          TibiaText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            color: TibiaStyle.white1
            text: widgetController ? widgetController.playerLevelToShow : 0
          }
        }

        TibiaHorizontalSeparator {
          visible: widgetController && widgetController.isShowAutoSpellList
          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginNarrow
          Layout.leftMargin: TibiaStyle.marginWide
          Layout.rightMargin: TibiaStyle.marginWide
        }

        // Spell list title
        TibiaText {
          visible: widgetController && widgetController.isShowAutoSpellList
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.marginNarrow
          color: TibiaStyle.white1
          text: qsTrId("playerguidewidget_newautospellslist_title")
        }

        // Automatically learned spells
        ListView {
          visible: widgetController && widgetController.isShowAutoSpellList
          model: widgetController ? widgetController.autoSpellList : null
          Layout.fillWidth: true
          Layout.preferredHeight: contentHeight
          spacing: TibiaStyle.marginNarrow

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens

          delegate: spellDelegate
        } // ListView

        TibiaText {
          visible: widgetController && widgetController.isShowManualSpellList
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.marginNarrow
          color: TibiaStyle.white1
          text: qsTrId("playerguidewidget_newmanualspellslist_title")
        }

        // Manually learned spells
        ListView {
          visible: widgetController && widgetController.isShowManualSpellList
          model: widgetController ? widgetController.manualSpellList : null
          Layout.fillWidth: true
          Layout.preferredHeight: contentHeight
          spacing: TibiaStyle.marginNarrow

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens

          delegate: spellDelegate
        } // ListView
      } // ColumnLayout

      Component {
        id: spellDelegate
        RowLayout {
            spacing: TibiaStyle.marginNarrow
            width: scrollView.availableWidth

            Image {
              Layout.preferredHeight: TibiaStyle.spellListIconSize
              Layout.leftMargin: TibiaStyle.marginNarrow
              source: model.iconID
            }

            TibiaText {
              Layout.fillWidth: true
              text: model.spellName
            }
          }
      }

      // Player Guide items
      ColumnLayout {
        id: playerGuideContentLayout
        visible: widgetController && widgetController.isShowPlayerGuideEntries
        anchors {
          left: parent.left; right: parent.right
        }

        // Upper part, latest player guide item
        ColumnLayout {
          visible: widgetController && widgetController.hasLatestUnlockedPlayerGuideEntry
          Layout.fillWidth: true

          TibiaText {
            Layout.fillWidth: true
            Layout.topMargin: TibiaStyle.marginUnrelated
            Layout.bottomMargin: TibiaStyle.marginUnrelated
            Layout.leftMargin: TibiaStyle.marginRelated
            text: qsTrId("playerguidewidget_unlocked_entries_recent")
          }

          TibiaButton {
            Layout.fillWidth: true
            Layout.leftMargin: TibiaStyle.marginRelated
            Layout.rightMargin: TibiaStyle.marginRelated
            Layout.bottomMargin: TibiaStyle.marginUnrelated
            implicitHeight: TibiaStyle.buttonHeightDefault * 2 + TibiaStyle.marginRelated
            textFont: TibiaStyle.defaultTextFont
            wrapText: true
            text: widgetController ? widgetController.latestUnlockedPlayerGuideEntry : ""

            onClicked: {
              if (widgetController != null) {
                widgetController.showLatestUnlockedPlayerGuide()
              }
            }
          } //TibiaButton
        } //ColumnLayout

        // Lower part, previous player guide items
        ColumnLayout {
          visible: widgetController && widgetController.hasPreviousUnlockedPlayerGuideEntries
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignTop

          TibiaHorizontalSeparator {
            Layout.fillWidth: true
            Layout.topMargin: TibiaStyle.marginRelated
            Layout.bottomMargin: TibiaStyle.marginRelated
            Layout.leftMargin: TibiaStyle.marginRelated
            Layout.rightMargin: TibiaStyle.marginRelated
          }

          TibiaText {
            Layout.fillWidth: true
            Layout.leftMargin: TibiaStyle.marginRelated
            text: qsTrId("playerguidewidget_unlocked_entries_previous")
          }

          ListView {
            id: previousUnlockedPlayerGuideEntriesListView
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight

            spacing: TibiaStyle.marginRelated
            model: widgetController ? widgetController.previousUnlockedPlayerGuideEntries : null

            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            delegate: TibiaButton {
              Layout.fillWidth: true
              Layout.topMargin: TibiaStyle.marginRelated
              Layout.bottomMargin: TibiaStyle.marginRelated
              anchors {
                left: parent.left; right: parent.right;
                leftMargin: TibiaStyle.marginRelated
                rightMargin: TibiaStyle.marginRelated
              }
              textHorizontalAlignment: Text.AlignLeft
              textXOffset: TibiaStyle.marginRelated
              text: model.playerGuideHeader

              onClicked: {
                if (widgetController != null) {
                  widgetController.showPreviousUnlockedPlayerGuide(model.newsEntryID)
                }
              }
            } //delegate TibiaButton
          } //ListView
        } //ColumnLayout
      } //ColumnLayout

      // Special Level popup
      Item {
        id: levelSpecialPopupContentLayout
        visible: widgetController && widgetController.isShowLevelSpecialPopup
        anchors {
          left: parent.left; right: parent.right;
        }
        height: scrollView.height

        TibiaButton {
          id: levelSpecialPopupButton
          anchors {
            centerIn: parent
          }
          implicitHeight: TibiaStyle.buttonHeightDefault * 2 + TibiaStyle.marginRelated
          implicitWidth: parent.width - TibiaStyle.marginRelated * 2
          textFont: TibiaStyle.defaultTextFont
          wrapText: true
          text: widgetController ? widgetController.levelSpecialPopupName : ""

          onClicked: {
            if (widgetController != null) {
              widgetController.showLevelSpecialPopup()
            }
          }

          TibiaRectangleHighlight {}

        } //TibiaButton

        TibiaText {
          anchors {
            left: parent.left
            right: parent.right
            bottom: levelSpecialPopupButton.top
            leftMargin: TibiaStyle.marginRelated
            rightMargin: TibiaStyle.marginRelated
            bottomMargin: TibiaStyle.marginWide
          }
          horizontalAlignment: Text.Center
          text: qsTrId("playerguidewidget_level_special_popup_button_caption")
        } //TibiaText
      } //ColumnLayout
    } //Flickable
  } //TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("playerguidewidget_lenshelp_caption")
    content: qsTrId("playerguidewidget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
