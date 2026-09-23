import QtQuick
import QtQuick.Layouts
import QtQml.Models
import Qt5Compat.GraphicalEffects

import qmlcomponents

RowLayout {
  id: root
  property var controller
  property bool isPremium: false
  readonly property bool canBeChanged: controller.canBeChanged

  readonly property int leftColumnWidth: (232 + 120)
  readonly property int firstColumnHeight: 154

  property var selectedMod: modSelectionModel.model.rowData(modSelectionModel.currentIndex)

  spacing: TibiaStyle.marginRelated

  function releaseFocusFromSearchField() {
    root.focus = true
    searchField.focus = false
  } //function releaseFocusFromSearchField

  Connections {
    target: modSelectionModel.model

    function resetSelection() {
      modSelectionModel.setCurrentIndex(modSelectionModel.model.index(0, 0), ItemSelectionModel.ClearAndSelect)
    }
    function rebindSelectedMod() {
      selectedMod = Qt.binding(function() { return modSelectionModel.model.rowData(modSelectionModel.currentIndex); })
    }

    function onDataChanged(topLeftModelIndex, bottomRightModelIndex, roles) {
      if (!modSelectionModel.currentIndex.valid) {
        resetSelection();
      }
      rebindSelectedMod()
    }
    function onRowsInserted(parent, firstIndex, lastIndex) {
      // This happens, for example, when the page changes, so it makes sense to reset the index here
      resetSelection()
      rebindSelectedMod()
    }
    function onRowsRemoved(parent, firstIndex, lastIndex) {
      if (!modSelectionModel.currentIndex.valid) {
        resetSelection()
        rebindSelectedMod()
      }
    }
    function onPaginationDataChanged() {
      if (!modSelectionModel.currentIndex.valid) {
        resetSelection()
        rebindSelectedMod()
      }
    }
  }



  ItemSelectionModel {
    id: modSelectionModel
    // This is the pagination model, and model.sourceModel
    // refers to the original filter model.
    model: root.controller.modList

    property var shouldBeCurrentIndex: root.controller.selectedModIndex

    onShouldBeCurrentIndexChanged: {
      if (model) {
        setCurrentIndex(shouldBeCurrentIndex, ItemSelectionModel.ClearAndSelect)
      }
    }

    onModelChanged: (model) => {
      if (model && !root.controller.selectedModIndex.valid) {
        setCurrentIndex(model.index(0, 0), ItemSelectionModel.ClearAndSelect)
      } else if (model && root.controller.selectedModIndex.valid) {
        setCurrentIndex(shouldBeCurrentIndex, ItemSelectionModel.ClearAndSelect)
      }
    }

    onCurrentIndexChanged: {
      // restart all animations
      if (typeof topCircleSeqAnimation !== 'undefined') {
        topCircleSeqAnimation.restart();
        lineSeqAnimation1.restart();
        midCircleSeqAnimation.restart();
        lineSeqAnimation2.restart();
        midCircleSeqAnimation2.restart();
        lineSeqAnimation3.restart();
        bottomCircleSeqAnimation.restart();
      }
      root.controller.selectedModIndex = currentIndex;
    }
  }


  // Left panel: Enhance Mod Grade
  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("skill_wheel_fragment_workshop_enhance_mod_grade_caption")
    Layout.preferredWidth: root.leftColumnWidth
    Layout.fillHeight: true

    Component {
      id: enhanceModComponent

      ColumnLayout {
        id: enhanceComponent

        spacing: TibiaStyle.marginUnrelated * 2

        property bool showLesserFragment: selectedMod.isBasicMod
        property bool supremeMod: !selectedMod.isBasicMod

        property string circleBackgroundImage: ""
        property string lineBackgroundImage: ""
        property url modImageSource: selectedMod.modImageSource
        property int currentModGrade: selectedMod.grade

        property int enhanceCostGold: selectedMod.isBasicMod ? (controller.getGoldCostsForBasicModWithGrade(currentModGrade)) : (controller.getGoldCostsForSupremeModWithGrade(currentModGrade))
        property int enhanceCostFragments: controller.getFragmentCostsForGrade(currentModGrade)

        property string bonusGrade1: selectedMod.grade1Bonus
        property string bonusGrade2: selectedMod.grade2Bonus
        property string bonusGrade3: selectedMod.grade3Bonus
        property string bonusGrade4: selectedMod.grade4Bonus

        TibiaText {
          text: selectedMod.augmentName

          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginUnrelated * 4
          horizontalAlignment: Text.AlignHCenter
        }

        // oberer Teil
        Item {
          id: itemWithCircles

          property int circlesLeftMargin: 5*TibiaStyle.marginRelated

          Layout.leftMargin: circlesLeftMargin
          Layout.fillWidth: true
          Layout.fillHeight: true

          // grade iv
          Image {
            id: firstCircle
            source: "/images/skillwheel/backdrop_grades_circle_top.png"


            Image {
              id: topCircleAnimation
              anchors.centerIn: parent
              visible: selectedMod.grade >= 3
              SequentialAnimation {

                id: topCircleSeqAnimation
                running: selectedMod.grade >= 3
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/0"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/1"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/2"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/3"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/4"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/5"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/6"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/7"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/8"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/9"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/10"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/11"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/12"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/13"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/14"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/15"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/16"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/17"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/18"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/19"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/20"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/21"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/22"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/23"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/24"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/25"; duration: 150 }
                PropertyAnimation { target: topCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-top/26"; duration: 150 }

              } //SequentialAnimation
            } //Image

            Image {
            id: modSaturationTarget4
            anchors.centerIn: parent
            source: controller.getModGradeImageSource(3)
            visible: enhanceComponent.modImageSource != ""
            width: implicitWidth
            height: implicitHeight

              Image {
                id: gemModImage4
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: enhanceComponent.supremeMod ? 3 : 0
                anchors.verticalCenterOffset: enhanceComponent.supremeMod ? -2 : 0
                source: enhanceComponent.modImageSource
              } // Image
            } // Image

            HueSaturation {
              anchors.centerIn: parent
              width: modSaturationTarget4.width
              height: modSaturationTarget4.height
              saturation: selectedMod.grade >= 3 ? 0.0 : -1.0
              source: modSaturationTarget4
            } // HueSaturation

          } // Image


          // line
          Image {
            id: firstLine

            anchors.top: firstCircle.bottom
            anchors.horizontalCenter: firstCircle.horizontalCenter

            source: "/images/skillwheel/backdrop_grades_line.png"


            Image {
              id: lineAnimation1
              anchors.centerIn: parent
              visible: selectedMod.grade >= 3
              SequentialAnimation {
                id: lineSeqAnimation1
                running: selectedMod.grade >= 3
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/0"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/1"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/2"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/3"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/4"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/5"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/6"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/7"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/8"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/9"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/10"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/11"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/12"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/13"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/14"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/15"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/16"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/17"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/18"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/19"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/20"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/21"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/22"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/23"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/24"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/25"; duration: 150 }
                PropertyAnimation { target: lineAnimation1; property: "source"; to: "image://backdrop-grades-line/26"; duration: 150 }

              } //SequentialAnimation
            } //Image


          } // Image


          TibiaText {
            text: qsTrId("skill_wheel_atelier_grade_4_text").arg(enhanceComponent.bonusGrade4)
            anchors.left: firstCircle.right
            anchors.verticalCenter: firstCircle.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 1*TibiaStyle.marginRelated
            anchors.horizontalCenter: firstCircle.right
            anchors.horizontalCenterOffset: (leftColumnWidth - itemWithCircles.circlesLeftMargin - firstCircle.width)/2
            styleType: (selectedMod.grade == 3) ? "Dialog" : "Disabled"
          }

          // grade iii
          Image {
            id: secondCircle
            source: "/images/skillwheel/backdrop_grades_circle_mid.png"

            anchors.top: firstLine.bottom
            anchors.horizontalCenter: firstLine.horizontalCenter

            Image {
              id: midCircleAnimation
              anchors.centerIn: parent
              visible: selectedMod.grade >= 2
              SequentialAnimation {
                id: midCircleSeqAnimation
                running: selectedMod.grade >= 2
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/0"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/1"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/2"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/3"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/4"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/5"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/6"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/7"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/8"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/9"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/10"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/11"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/12"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/13"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/14"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/15"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/16"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/17"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/18"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/19"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/20"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/21"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/22"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/23"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/24"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/25"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-mid/26"; duration: 150 }

              } //SequentialAnimation
            } //Image

            Image {
            id: modSaturationTarget3
            anchors.centerIn: parent
            source: controller.getModGradeImageSource(2)
            visible: enhanceComponent.modImageSource != ""
            width: implicitWidth
            height: implicitHeight

              Image {
                id: gemModImage3
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: enhanceComponent.supremeMod ? 3 : 0
                anchors.verticalCenterOffset: enhanceComponent.supremeMod ? -2 : 0
                source: enhanceComponent.modImageSource
              } // Image
            } // Image

            HueSaturation {
              anchors.centerIn: parent
              width: modSaturationTarget3.width
              height: modSaturationTarget3.height
              saturation: selectedMod.grade >= 2 ? 0.0 : -1.0
              source: modSaturationTarget3
            } // HueSaturation


          } // Image


          // line
          Image {
            id: secondLine

            anchors.top: secondCircle.bottom
            anchors.horizontalCenter: secondCircle.horizontalCenter

            source: "/images/skillwheel/backdrop_grades_line.png"

            Image {
              id: lineAnimation2
              anchors.centerIn: parent
              visible: selectedMod.grade >= 2
              SequentialAnimation {
                id: lineSeqAnimation2
                running: selectedMod.grade >= 2
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/0"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/1"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/2"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/3"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/4"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/5"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/6"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/7"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/8"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/9"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/10"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/11"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/12"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/13"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/14"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/15"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/16"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/17"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/18"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/19"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/20"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/21"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/22"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/23"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/24"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/25"; duration: 150 }
                PropertyAnimation { target: lineAnimation2; property: "source"; to: "image://backdrop-grades-line/26"; duration: 150 }

              } //SequentialAnimation
            } //Image
          } // Image


          TibiaText {
            text: qsTrId("skill_wheel_atelier_grade_3_text").arg(enhanceComponent.bonusGrade3)
            anchors.left: secondCircle.right
            anchors.verticalCenter: secondCircle.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 1*TibiaStyle.marginRelated
            anchors.horizontalCenter: secondCircle.right
            anchors.horizontalCenterOffset: (leftColumnWidth - itemWithCircles.circlesLeftMargin - secondCircle.width)/2
            styleType: (selectedMod.grade == 2) ? "Dialog" : "Disabled"
          } // TibiaText

          // grade ii
          Image {
            id: thirdCircle
            source: "/images/skillwheel/backdrop_grades_circle_mid.png"

            anchors.top: secondLine.bottom
            anchors.horizontalCenter: secondLine.horizontalCenter

            Image {
              id: midCircleAnimation2
              anchors.centerIn: parent
              visible: selectedMod.grade >= 1
              SequentialAnimation {
                id: midCircleSeqAnimation2
                running: selectedMod.grade >= 1
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/0"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/1"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/2"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/3"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/4"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/5"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/6"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/7"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/8"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/9"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/10"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/11"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/12"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/13"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/14"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/15"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/16"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/17"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/18"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/19"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/20"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/21"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/22"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/23"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/24"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/25"; duration: 150 }
                PropertyAnimation { target: midCircleAnimation2; property: "source"; to: "image://backdrop-grades-circle-mid/26"; duration: 150 }

              } //SequentialAnimation
            } //Image


            Image {
              id: modSaturationTarget2
              anchors.centerIn: parent
              source: controller.getModGradeImageSource(1)
              visible: enhanceComponent.modImageSource != ""
              width: implicitWidth
              height: implicitHeight

              Image {
                id: gemModImage2
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: enhanceComponent.supremeMod ? 3 : 0
                anchors.verticalCenterOffset: enhanceComponent.supremeMod ? -2 : 0
                source: enhanceComponent.modImageSource
              } // Image
            } // Image

            HueSaturation {
              anchors.centerIn: parent
              width: modSaturationTarget2.width
              height: modSaturationTarget2.height
              saturation: selectedMod.grade >= 1 ? 0.0 : -1.0
              source: modSaturationTarget2
            } // HueSaturation

          } // Image


          // line
          Image {
            id: thirdLine
            source: "/images/skillwheel/backdrop_grades_line.png"

            anchors.top: thirdCircle.bottom
            anchors.horizontalCenter: thirdCircle.horizontalCenter

            Image {
              id: lineAnimation3
              anchors.centerIn: parent
              visible: selectedMod.grade >= 1
              SequentialAnimation {
                id: lineSeqAnimation3
                running: selectedMod.grade >= 1
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/0"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/1"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/2"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/3"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/4"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/5"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/6"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/7"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/8"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/9"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/10"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/11"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/12"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/13"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/14"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/15"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/16"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/17"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/18"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/19"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/20"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/21"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/22"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/23"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/24"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/25"; duration: 150 }
                PropertyAnimation { target: lineAnimation3; property: "source"; to: "image://backdrop-grades-line/26"; duration: 150 }

              } //SequentialAnimation
            } //Image

          } // Image


          TibiaText {
            text: qsTrId("skill_wheel_atelier_grade_2_text").arg(enhanceComponent.bonusGrade2)
            anchors.left: thirdCircle.right
            anchors.verticalCenter: thirdCircle.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 1*TibiaStyle.marginRelated
            anchors.horizontalCenter: thirdCircle.right
            anchors.horizontalCenterOffset: (leftColumnWidth - itemWithCircles.circlesLeftMargin - thirdCircle.width)/2
            styleType: (selectedMod.grade == 1) ? "Dialog" : "Disabled"
          } // TibiaText

          // grade i
          Image {
            id: fourthCircle
            source: "/images/skillwheel/backdrop_grades_circle_bottom.png"

            anchors.top: thirdLine.bottom
            anchors.horizontalCenter: thirdLine.horizontalCenter

            Image {
              id: bottomCircleAnimation
              anchors.centerIn: parent
              visible: selectedMod.grade >= 0
              SequentialAnimation {
                id: bottomCircleSeqAnimation
                running: selectedMod.grade >= 0
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/0"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/1"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/2"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/3"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/4"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/5"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/6"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/7"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/8"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/9"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/10"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/11"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/12"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/13"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/14"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/15"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/16"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/17"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/18"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/19"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/20"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/21"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/22"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/23"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/24"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/25"; duration: 150 }
                PropertyAnimation { target: bottomCircleAnimation; property: "source"; to: "image://backdrop-grades-circle-bottom/26"; duration: 150 }

              } //SequentialAnimation
            } //Image

            Image {
            id: modSaturationTarget1
            anchors.centerIn: parent
            source: controller.getModGradeImageSource(0)
            visible: enhanceComponent.modImageSource != ""
            width: implicitWidth
            height: implicitHeight

              Image {
                id: gemModImage1
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: enhanceComponent.supremeMod ? 3 : 0
                anchors.verticalCenterOffset: enhanceComponent.supremeMod ? -2 : 0
                source: enhanceComponent.modImageSource
              } // Image
            } // Image
          } // Image

          TibiaText {
            text: qsTrId("skill_wheel_atelier_grade_1_text").arg(enhanceComponent.bonusGrade1)
            anchors.left: fourthCircle.right
            anchors.verticalCenter: fourthCircle.verticalCenter
            anchors.horizontalCenter: fourthCircle.right
            anchors.horizontalCenterOffset: (leftColumnWidth - itemWithCircles.circlesLeftMargin - fourthCircle.width)/2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 1*TibiaStyle.marginRelated
            styleType: (selectedMod.grade == 0) ? "Dialog" : "Disabled"
          } // TibiaText
        }



        // enhance button, currency views
        RowLayout {
          spacing: TibiaStyle.marginNarrow
          Layout.bottomMargin: TibiaStyle.marginRelated
          Layout.leftMargin: TibiaStyle.marginRelated

          Item {
            // Workaround for tooltip + disabled element
            width: enhanceButton.width
            height: enhanceButton.height

            TibiaButton {
              id: enhanceButton
              text: qsTrId("skill_wheel_atelier_enhance")
              width: TibiaStyle.buttonWidthBroad
              enabled: !enhanceCostView.tooLowBalance && !enhanceFragmentCostView.tooLowBalance && root.isPremium && root.canBeChanged && selectedMod.grade < 3
              visible: selectedMod.grade < 3

              onClicked: {
                root.controller.enhanceModGrade(selectedMod.isBasicMod, selectedMod.modID);
              }
            } // TibiaButton

            Tooltip {
              anchors.fill: parent
              text: {
                if (enhanceButton.enabled || !enhanceButton.visible) {
                  return "";
                }
                let messages = []
                if (enhanceCostView.tooLowBalance) {
                  messages.push(
                    qsTrId("skill_wheel_atelier_enhance_insufficient_money")
                      .arg(TextHelper.formatNumberWithThousandSeparators(enhanceComponent.enhanceCostGold)))
                }
                if (enhanceFragmentCostView.tooLowBalance && enhanceComponent.showLesserFragment) {
                  messages.push(
                    qsTrId("skill_wheel_atelier_enhance_insufficient_lesser_fragments")
                      .arg(TextHelper.formatNumberWithThousandSeparators(enhanceComponent.enhanceCostFragments)))
                }
                if (enhanceFragmentCostView.tooLowBalance && !enhanceComponent.showLesserFragment) {
                  messages.push(
                    qsTrId("skill_wheel_atelier_enhance_insufficient_greater_fragments")
                      .arg(TextHelper.formatNumberWithThousandSeparators(enhanceComponent.enhanceCostFragments)))
                }

                if (!root.isPremium) {
                  messages.push(qsTrId("skill_wheel_atelier_enhance_not_premium"))
                }
                if (!root.canBeChanged) {
                  messages.push(qsTrId("skill_wheel_atelier_enhance_not_in_temple"))
                }

                if (selectedMod.grade >= 3) {
                  messages.push(qsTrId("skill_wheel_atelier_enhance_already_max_grade"))
                }

                return messages.join("\n")
              }
            } // Tooltip
          } // Item


          TibiaCurrencyView {
            id: enhanceCostView
            Layout.preferredWidth: TibiaStyle.buttonWidthBroad
            iconId: "GoldCoin"
            rightAligned: true
            visible: selectedMod.grade < 3
            price: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(enhanceComponent.enhanceCostGold)
            tooLowBalance: enhanceComponent.enhanceCostGold > storeAndResourceBalanceHelper.totalGoldBalance
          }

          TibiaCurrencyView {
            id: enhanceFragmentCostView
            Layout.preferredWidth: TibiaStyle.buttonWidthBroad
            iconId: enhanceComponent.showLesserFragment ? "LesserFragments" : "GreaterFragments"
            rightAligned: true
            visible: selectedMod.grade < 3
            price: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(enhanceComponent.enhanceCostFragments)
            tooLowBalance: enhanceComponent.showLesserFragment ? (enhanceComponent.enhanceCostFragments > storeAndResourceBalanceHelper.lesserFragmentCount) : (enhanceComponent.enhanceCostFragments > storeAndResourceBalanceHelper.greaterFragmentCount)
          }

        }// RowLayout
      } // ColumnLayout
    } // Component

    Component {
      id: noModSelectedComponent

      TibiaText {
        text: qsTrId("skill_wheel_fragment_workshop_no_filtered_mods")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }

    Loader {
      anchors.fill: parent
      sourceComponent: root.selectedMod != null && root.selectedMod.modImageSource !== undefined ? enhanceModComponent : noModSelectedComponent
    }
  } //TibiaFrame2PixelUpFilledWithCaption


  // right part
  ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: TibiaStyle.marginRelated

    RowLayout {
      id: middleControlsLayout
      Layout.fillWidth: true
      Layout.preferredHeight: TibiaStyle.buttonHeightDefault

      spacing: TibiaStyle.marginRelated
      readonly property int filterControlsWidth: 155

      TibiaTextSearchField {
        id: searchField
        Layout.preferredWidth: middleControlsLayout.filterControlsWidth
        shouldBeText: modSelectionModel.model.sourceModel.filterModName

        onSearchTextChanged: {
          modSelectionModel.model.sourceModel.filterModName = searchText
        }

        Keys.onPressed: (event) => {
          if (focus && event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
            searchTextChanged();
            event.accepted = true;
            //avoid forward to OK-Button which closes the dialogue
          }
        } //Keys.onPressed

      } //TibiaTextSearchField

      TibiaComboBox {
        Layout.preferredWidth: middleControlsLayout.filterControlsWidth
        shouldBeCurrentIndex: controller.filterMods
        textRole: "text"
        valueRole: "value"
        model: ListModel {
          id: filterModsModel
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_all");
                        value: TibiaEnums.EFragmentWorkshopFilter.All }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_basic");
                        value: TibiaEnums.EFragmentWorkshopFilter.BasicMods }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_supreme");
                        value: TibiaEnums.EFragmentWorkshopFilter.SupremeMods }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_socketed");
                        value: TibiaEnums.EFragmentWorkshopFilter.SocketedMods }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_grade1");
                        value: TibiaEnums.EFragmentWorkshopFilter.Grade1 }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_grade2");
                        value: TibiaEnums.EFragmentWorkshopFilter.Grade2 }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_grade3");
                        value: TibiaEnums.EFragmentWorkshopFilter.Grade3 }
          ListElement { text: qsTrId("skill_wheel_fragment_workshop_mods_filter_grade4");
                        value: TibiaEnums.EFragmentWorkshopFilter.Grade4 }
        }

        onActivated: (index) => {
          modSelectionModel.model.sourceModel.filterMods = filterModsModel.get(index).value
          controller.filterMods = filterModsModel.get(index).value;
        }
      }


      TibiaButton {
        Layout.leftMargin: TibiaStyle.marginWide - parent.spacing
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: TibiaStyle.buttonHeightDefault
        enabled: modSelectionModel.model.hasPreviousPage

        onClicked: {
          modSelectionModel.model.currentPage -= 1
        }
      } // TibiaButton

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: qsTrId("skill_wheel_fragment_workshop_page_count_total")
          .arg(modSelectionModel.model.currentPage)
          .arg(modSelectionModel.model.numberOfPages)
          .arg(modSelectionModel.model.sourceModel.rowCount())
      } // TibiaText

      TibiaButton {
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: TibiaStyle.buttonHeightDefault
        imageMirrored: true
        enabled: modSelectionModel.model.hasNextPage

        onClicked: {
          modSelectionModel.model.currentPage += 1
        }
      } // TibiaButton
    } // RowLayout

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.fillHeight: true

      GridView {
        id: modsGrid
        anchors.fill: parent
        anchors.margins: parent.borderWidth

        interactive: false
        boundsBehavior: Flickable.StopAtBounds

        readonly property int rowCount: 6
        readonly property int columnCount: 5
        readonly property int spacing: TibiaStyle.marginRelated
        cellWidth: Math.ceil((width / columnCount) - (spacing / columnCount))
        cellHeight: Math.ceil((height / rowCount) - (spacing / rowCount))

        model: modSelectionModel.model

        delegate: MouseArea {
          id: gridCell

          required property int index
          required property bool isSocketed
          required property bool isBasicMod
          required property url modImageSource
          required property string modName
          required property int amountOnGemsInAtelier
          required property int grade


          width: modsGrid.cellWidth
          height: modsGrid.cellHeight

          onClicked: (mouse) => {
            modSelectionModel.setCurrentIndex(modsGrid.model.index(index, 0), ItemSelectionModel.ClearAndSelect)
            modsGrid.currentIndex = index

            releaseFocusFromSearchField();
          }

          TibiaFrame2PixelUpFilled {
            width: modsGrid.cellWidth - modsGrid.spacing
            height: modsGrid.cellHeight - modsGrid.spacing
            anchors { bottom: parent.bottom; right: parent.right; }

            Rectangle {
              anchors.fill: parent
              anchors.margins: -3
              color: "transparent"
              border { color: "white"; width: 2 }
              visible: modSelectionModel.currentIndex == modsGrid.model.index(gridCell.index, 0)
            }


            Image {
              id: modGradeBorder
              anchors.centerIn: parent
              source: controller.getModGradeImageSource(gridCell.grade)
              visible: gridCell.modImageSource != ""
              width: implicitWidth
              height: implicitHeight

              Image {

                anchors.centerIn: parent
                anchors.horizontalCenterOffset: !isBasicMod ? 3 : 0
                anchors.verticalCenterOffset: !isBasicMod ? -2 : 0
                source: gridCell.modImageSource

                Tooltip {
                anchors.fill: parent
                text: gridCell.modName
              }

              } // Image
            } // Image


            Image { // socketed image
              anchors { margins: parent.marginsToContent + TibiaStyle.marginNarrow;
                        left: parent.left; top: parent.top }
              source: isSocketed ? "/images/skillwheel/icon-socketed.png" : ""
              Tooltip {
                text: isSocketed ? qsTrId("skill_wheel_fragment_workshop_socketed_tooltip") : ""
                anchors.fill: parent
              } // Tooltip
            } // Image

            TibiaText { // amount on gems in atelier
              anchors { margins: parent.marginsToContent + TibiaStyle.marginNarrow;
                        right: parent.right; top: parent.top }
              text: qsTrId("skill_wheel_fragment_workshop_amount_text").arg(gridCell.amountOnGemsInAtelier)
              visible: gridCell.amountOnGemsInAtelier > 0
              Tooltip {
                text: gridCell.amountOnGemsInAtelier > 0 ? qsTrId("skill_wheel_fragment_workshop_amount_tooltip").arg(gridCell.amountOnGemsInAtelier) : ""
                anchors.fill: parent
              } // Tooltip
            } // TibiaText


          } // TibiaFrame2PixelUpFilled
        } // Item
      } // GridView
    } // TibiaFrame1PixelDown
  } // ColumnLayout
} // RowLayout
