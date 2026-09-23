import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues
import "qrc:/qt/qml/qmlcomponents/qml/"

import QtQuick.LegacyControls

TibiaDialog {
  id: soulTicketsDialog
  caption: qsTrId("soul_seals_dialog_caption")
  width: 358
  height: 412

  required property var controller
  
  initialFocusItem: soulTicketsDialog
  KeyNavigation.tab: soulTicketsDialog
  
  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }
  
  
  ColumnLayout {
  
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated
  
    TibiaFrame2PixelUpFilled {
    
      Layout.preferredHeight: 329
      Layout.preferredWidth: 326

      ColumnLayout {
        
        anchors.fill: parent
        anchors.margins: TibiaStyle.marginUnrelated
        spacing: TibiaStyle.marginUnrelated
      
        RowLayout {
        
          Layout.preferredHeight: 21
          Layout.alignment: Qt.AlignHCenter
          spacing: TibiaStyle.marginUnrelated
                      
          TibiaTextSearchField {
            id: nameFilterText
          
            Layout.preferredHeight: 20
            Layout.preferredWidth: 141
            Layout.column: 0
            Layout.row: 0
          
            maximumLength: TibiaStyle.maxCharacterNameLength
            //enabled: rootElement.monsterSelectionIsPossible
            KeyNavigation.tab: nameFilterText
            KeyNavigation.backtab: nameFilterText
            shouldBeText: controller.monstersNameFilter
            onSearchTextChanged: {
              if (controller != null) {
                controller.monstersNameFilter = text;
                soulSealsTable.filterSettingsChanged();
              }
            } //onTextChanged
          } // TibiaTextField
          
          TibiaComboBox {
          
            id: monsterDifficultySelectionBox
            Layout.preferredWidth: 150
            model: controller.availableMonsterDifficulties
            shouldBeCurrentIndex: controller.indexOfSelectedDifficulty

            onModelChanged: {
              currentIndex = controller.indexOfSelectedDifficulty;
            }

            onActivated: {
              if (controller) {
                controller.indexOfSelectedDifficulty = currentIndex;
                soulSealsTable.filterSettingsChanged();
              }
            }
          } // TibiaComboBox
        
        } // RowLayout
        
        
        // die scroll box
        
        TibiaTableView {
            id: soulSealsTable
            Layout.preferredWidth: 306
            Layout.fillHeight: true
            model: controller.monsterList
            rowHeight: 36 // TO DO
            headerVisible: true
            selectionMode: SelectionMode.SingleSelection
        
            selection.onSelectionChanged: {
              controller.selectedMonsterRaceID = 0;
              selection.forEach(function(rowIndex) {
                controller.selectedMonsterRaceID = model.getRaceIDAtIndex(rowIndex);
              });
            } //selection.onSelectionChanged
            
                   
            function filterSettingsChanged() {    
              controller.selectedMonsterRaceID = 0;
              soulSealsTable.selection.clear();
              soulSealsTable.currentRow = -1;
            }
        
            TableViewColumn {
              role: "raceID"
              title: qsTrId("soul_seals_dialog_column_monster")
              movable: false
              resizable: false
              width: 197
        
              delegate: RowLayout {
                property int monsterRaceID: model != null ? model.raceId : 0
                
                RaceAppearanceInstanceRenderer {
                  id: monsterOutfit
                  width: 32
                  height: 32
                  raceID: monsterRaceID
                  isUnknown: false
                } // RaceAppearanceInstanceRenderer

        
                TibiaText {
                  text: model != null && model.name.length > 0 ? model.name : qsTrId("dummy_unknown")
                  verticalAlignment: Text.AlignVCenter
                  Layout.fillWidth: true
                  Layout.fillHeight: true

                  Image {
                    visible: (model != null) && model.animusMasteryCompleted

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: -TibiaStyle.marginRelated
                                        
                    source: "/images/indicator_soulcore.png"
                    
                    mirror: true
                  }
                } // TibiaText
        
                TibiaVerticalSeparator {
                  Layout.fillHeight: true
                } //TibiaVerticalSeparator
              } // RowLayout
            } // TableViewColumn
        
            TableViewColumn {
              role: "totalAmount"
              title: qsTrId("soul_seals_dialog_column_soulseals")
              movable: false
              resizable: false
              width: 90
        
              delegate: Item {
                
                anchors.fill: parent
                
                TibiaText {
                  id: priceText
                  text: model != null ?
                    TextHelper.formatNumberWithThousandSeparators(model.soulPitFightPrice) :
                    qsTrId("dummy_unknown")
               
                  verticalAlignment: Text.AlignVCenter
                  horizontalAlignment: Text.AlignRight
                  
                  anchors.right: priceImage.left
                  anchors.verticalCenter: priceImage.verticalCenter
                  anchors.rightMargin: TibiaStyle.marginNarrow
                  
                } // TibiaText
                
                Image {
                  id: priceImage
                  source: "/images/taskboard/icon-currency-soulseals.png"
                  
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                }
              } // Item
              
            } // TableViewColumn
        } // TibiaTableView
      
        RowLayout {
        
           TibiaFrame1PixelDown {
           
             Layout.alignment: Qt.AlignRight
      
             id: frame
             height: TibiaStyle.mapWindowPixelPerField * 2
             width: TibiaStyle.mapWindowPixelPerField * 2
             
             z: -1
             BorderImage {
               smooth: false
               anchors.fill: parent
               anchors.margins: 1
               source: "/images/backdrop-dark-grey.png"
               horizontalTileMode: BorderImage.Repeat
               verticalTileMode: BorderImage.Repeat
               visible: true
               cache: false
               
               RaceAppearanceInstanceRenderer {
                  id: monsterOutfit
                  width: 64
                  height: 64
                  anchors.centerIn: parent
                  anchors.leftMargin: 15
                  anchors.bottomMargin: 19
                  raceID: controller.selectedMonsterRaceID
                  isUnknown: false
               } // RaceAppearanceInstanceRenderer
               
               
             } // BorderImage
           
           } // TibiaFrame1PixelDown
           
           ColumnLayout {
           
             Layout.alignment: Qt.AlignTop
             Layout.margins: TibiaStyle.marginUnrelated
             spacing: TibiaStyle.marginUnrelated
             
             TibiaText {
               text: controller.selectedMonstername
               verticalAlignment: Text.AlignVCenter
               
               Layout.alignment: Qt.AlignLeft
             } // TibiaText
           
             RowLayout {
               Layout.alignment: Qt.AlignLeft
               spacing: 0
               
               TibiaButton {
                 id: fightButton
                 
                 Layout.alignment: Qt.AlignRight
                 text: qsTrId("soul_seals_dialog_fight_button")
                 
                 enabled: (controller.selectedMonsterRaceID != 0) && (controller.availableSoulSeals >= controller.selectedFightPrice)
               
                 onClicked: controller.fightselectedMonster();
               } // TibiaButton
               
               TibiaCurrencyView {
                 Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
                 balance: controller.selectedFightPrice
                 rightAligned: true
                 iconId: "SoulSeals"
               } // TibiaCurrencyView
               
               TibiaGuiHelp {
                 text:qsTrId("soulseals_fight_gui_help")
                 Layout.leftMargin: TibiaStyle.marginRelated
               }
               
           
             } // RowLayout

           } // ColumnyLayout
        
        } // RowLayout
      
      } // ColumnLayout
      
    } // TibiaFrame2PixelUpFilled
  
    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }
    
    RowLayout{
    
      Layout.fillWidth: true
      
      TibiaCurrencyView {
        Layout.alignment: Qt.AlignLeft
        Layout.preferredWidth: TibiaStyle.currencyViewWidth
        balance: controller.soulSealsString
        rightAligned: true
        iconId: "SoulSeals"
      } // TibiaCurrencyView
      
      Item {
        Layout.fillWidth: true
      }
    
      TibiaButton {
        id: closeButton
        
        Layout.alignment: Qt.AlignRight
        text: qsTrId("close")

        onClicked: onCancelPressedFunction();
      } // TibiaButton
    
    } // RowLayout
  
  } // ColumnLayout


} // TibiaDialog
