import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml

import qmlcomponents

TibiaDialog {
    caption: qsTrId("boss_difficulty_selection_caption")
    headerDelegate: DialogHeaderDragon {}
    width: 840
    required property var controller
    
    ColumnLayout {
        id: content
        spacing: TibiaStyle.marginRelated

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        RowLayout {
            spacing: TibiaStyle.marginRelated

            TibiaFrame2PixelUpFilledWithCaption {
                Layout.preferredWidth: 302
                caption: raceAppearanceRenderer.raceName
                Layout.preferredHeight: innerGrid.implicitHeight + captionHeight + borderWidth * 2 + 2 * TibiaStyle.marginUnrelated
                Layout.fillHeight: true

                ColumnLayout {
                    id: innerGrid

                    anchors {
                        fill: parent
                        topMargin: parent.borderWidth + TibiaStyle.marginUnrelated
                        leftMargin: parent.borderWidth + TibiaStyle.marginUnrelated
                        rightMargin: parent.borderWidth + TibiaStyle.marginUnrelated
                        bottomMargin: parent.borderWidth + TibiaStyle.marginUnrelated
                    }

                    Item {
                        id: bossPodestal
                        property real scaleFactor: 2.0

                        Layout.preferredHeight: Math.max(podest.height, raceAppearanceRenderer.height + 19 * scaleFactor)
                        Layout.preferredWidth: innerGrid.width

                        Image {
                            source: "/images/bossdifficultysel/bds_fire_column_base.png"
                            height: sourceSize.height * parent.scaleFactor
                            width: sourceSize.width * parent.scaleFactor
                            smooth: false

                            x: podest.x - 36 * parent.scaleFactor
                            y: podest.y + 10 * parent.scaleFactor

                            Image {
                                id: fireBowlFlameLeft
                                scale: bossPodestal.scaleFactor
                                transformOrigin: Item.TopLeft
                                smooth: false

                                x: -3 * bossPodestal.scaleFactor
                                y: -20 * bossPodestal.scaleFactor

                                SequentialAnimation {
                                    running: true
                                    loops: Animation.Infinite
                                    alwaysRunToEnd: true

                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/0"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/1"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/2"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/3"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/4"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/5"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/6"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/7"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameLeft; property: "source"; to: "image://fire-bowl-animation/8"; duration: 100 }
                                } //SequentialAnimation
                            }
                        }

                        Image {
                            id: podest
                            source: "/images/boostedbosspodestal.png"
                            x: Math.floor((parent.width - width) / 2 + 8)

                            height: sourceSize.height * parent.scaleFactor
                            anchors.bottom: parent.bottom
                            width: sourceSize.width * parent.scaleFactor
                            smooth: false

                            RaceAppearanceInstanceRenderer {
                                id: raceAppearanceRenderer
                                width: 64 * bossPodestal.scaleFactor
                                height: 64 * bossPodestal.scaleFactor
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 16 * bossPodestal.scaleFactor
                                anchors.bottomMargin: 19 * bossPodestal.scaleFactor
                                raceID: controller.raceId
                                scaleFactor: bossPodestal.scaleFactor
                                maxScaleFactorForAutoFit: scaleFactor
                                smoothTextureFiltering: false
                                autofit: false
                                center: true
                                moving: true
                            } //RaceAppearanceInstanceRenderer
                        }

                        Image {
                            source: "/images/bossdifficultysel/bds_fire_column_base.png"
                            height: sourceSize.height * parent.scaleFactor
                            width: sourceSize.width * parent.scaleFactor
                            smooth: false

                            x: podest.x + 56 * parent.scaleFactor
                            y: podest.y + 10 * parent.scaleFactor

                            Image {
                                id: fireBowlFlameRight
                                scale: bossPodestal.scaleFactor
                                transformOrigin: Item.TopLeft
                                smooth: false

                                x: -3 * bossPodestal.scaleFactor
                                y: -20 * bossPodestal.scaleFactor

                                SequentialAnimation {
                                    running: true
                                    loops: Animation.Infinite
                                    alwaysRunToEnd: true

                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/6"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/7"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/8"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/0"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/1"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/2"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/3"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/4"; duration: 100 }
                                    PropertyAnimation { target: fireBowlFlameRight; property: "source"; to: "image://fire-bowl-animation/5"; duration: 100 }
                                } //SequentialAnimation
                            }
                        }
                    } //Image

                    TibiaText {
                        Layout.alignment: Qt.AlignHCenter
                        text: controller.isActiveUser ? qsTrId("boss_difficulty_selection_difficulty_selection") : qsTrId("boss_difficulty_selection_difficulty_selection_passive")
                    }

                    Loader {
                        Layout.alignment: Qt.AlignHCenter
                        sourceComponent: controller.isActiveUser ? spinBoxComponent : labelComponent
                        
                        Component {
                            id: spinBoxComponent
                            TibiaSpinBox {
                                initialValue: controller.selectedDifficulty
                                minValue: controller.lowestDifficulty
                                maxValue: controller.highestDifficultyOfGroup
                                
                                onCurrentValueChanged: {
                                    controller.setSelectedDifficulty(currentValue);
                                }
                            }
                        }

                        Component {
                            id: labelComponent
                            TibiaText {
                                text: controller.selectedDifficulty
                            }
                        }
                    }

                    TibiaHorizontalSeparator {
                        Layout.topMargin: TibiaStyle.marginRelated
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 30

                        TibiaText {
                            text: qsTrId("boss_difficulty_selection_highest_group_diff")
                        }

                        TibiaText {
                            text: controller.highestDifficultyOfGroup
                            Layout.fillWidth: true
                        }

                        TibiaText {
                            text: qsTrId("boss_difficulty_selection_highest_personal_diff")
                        }

                        TibiaText {
                            text: controller.personalHighestDifficulty
                        }

                        TibiaText {
                            text: qsTrId("boss_difficulty_selection_bad_luck_bonus")
                        }

                        TibiaText {
                            text: parseFloat(controller.currentBadLuckDropBonus.toFixed(2)) + "%"
                        }
                    }
                }
            }

            TibiaFrame2PixelUpFilledWithCaption {
                Layout.fillWidth: true
                Layout.fillHeight: true
                caption: qsTrId("boss_difficulty_selection_difficulty_modifiers")

                ColumnLayout {
                    width: parent.width - (parent.borderWidth + TibiaStyle.marginUnrelated) * 2
                    height: parent.height - parent.captionHeight - TibiaStyle.marginUnrelated - (parent.borderWidth + TibiaStyle.marginUnrelated)
                    x: parent.borderWidth + TibiaStyle.marginUnrelated
                    y: parent.captionHeight + TibiaStyle.marginUnrelated


                    TibiaScrollView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        verticalScrollBarPolicy: ScrollBar.AsNeeded

                        ListView {
                            spacing: 5
                            width: parent.width
                            model: controller.conModifiers
                            delegate: RowLayout {
                                width: parent.width
                                Image {
                                    source: "/images/bossdifficultysel/bds_con_icon.png"
                                    Layout.alignment: Qt.AlignTop
                                }
                                TibiaText {
                                    text: modelData
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    TibiaHorizontalSeparator {
                        Layout.fillWidth: true
                        Layout.topMargin: TibiaStyle.marginRelated
                        Layout.bottomMargin: TibiaStyle.marginRelated
                    }

                    TibiaScrollView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        verticalScrollBarPolicy: ScrollBar.AsNeeded

                        ListView {
                            spacing: 5
                            width: parent.width
                            model: controller.proModifiers
                            delegate: RowLayout {
                                width: parent.width
                                Image {
                                    source: "/images/bossdifficultysel/bds_pro_icon.png"
                                    Layout.alignment: Qt.AlignTop
                                }
                                TibiaText {
                                    text: modelData
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        TibiaFrame2PixelUpFilled {
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            TibiaSunkenPillLabel {
                text: controller.playerNames[1]
                y: (parent.height - height) / 2
                x: startButton.x - width - 25
            }

            TibiaSunkenPillLabel {
                text: controller.playerNames[3]
                y: (parent.height - height) / 2 + 40
                x: startButton.x - width - 5
            }

            Image {
                id: startButton
                source: "/images/bossdifficultysel/bds_start_fight_button_frame.png"

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -15
                    horizontalCenter: parent.horizontalCenter
                }

                TibiaButton {
                    imageSourceUp: "/images/bossdifficultysel/bds_start_fight_icon_" + (enabled ? "enabled.png" : "disabled.png")
                    enabled: controller.isActiveUser
                    text: qsTrId("boss_difficulty_selection_start_fight")
                    textVerticalAlignment: Text.AlignBottom
                    textBottomPadding: TibiaStyle.marginUnrelated
                    imageYOffset: -TibiaStyle.marginUnrelated
                    textFont: TibiaStyle.defaultTextFont
                    anchors {
                        fill: parent
                        topMargin: 8
                        leftMargin: 8
                        rightMargin: 8
                        bottomMargin: 8
                    }
                    
                    onClicked: onReturnPressedFunction()
                }

                Image {
                    source: "/images/bossdifficultysel/bds_stone_flag_left.png"
                    x: -width + 4
                }

                Image {
                    source: "/images/bossdifficultysel/bds_stone_flag_right.png"
                    x: parent.width - 4
                }
            }

            TibiaSunkenPillLabel {
                text: controller.playerNames[0]
                anchors.horizontalCenter: parent.horizontalCenter
                y: (parent.height - height) / 2 + 50
            }

            TibiaSunkenPillLabel {
                text: controller.playerNames[2]
                y: (parent.height - height) / 2
                x: startButton.x + startButton.width + 25
            }

            TibiaSunkenPillLabel {
                text: controller.playerNames[4]
                y: (parent.height - height) / 2 + 40
                x: startButton.x + startButton.width + 5
            }
        }

        TibiaHorizontalSeparator {
            Layout.topMargin: TibiaStyle.marginRelated
            Layout.bottomMargin: TibiaStyle.marginRelated
        }

        TibiaButton {
            text: qsTrId("cancel")
            Layout.alignment: Qt.AlignRight
            onClicked: onCancelPressedFunction()
        }
    }

    onCancelPressedFunction: function() {
      controller.onCancelClicked();
    }

    onReturnPressedFunction: function() {
      controller.onStartClicked();
  }
}