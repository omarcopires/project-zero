import QtQuick
import QtQuick.Layouts
import QtQuick.LegacyControls



TibiaDialog {
  id: reportDialog
  width: 545

  property var controller: null
  property int dialogStep: 1
  property string dialogType: controller != null ? controller.dialogType : "bot" // Either bot, statement or name

  readonly property bool isNameReport: dialogType == "name" || dialogType == "bot" || dialogType == "hireling"
  readonly property bool isTextReport: dialogType == "statement" || dialogType == "text"

  property string displayedDialogType: {
    if (dialogType == "bot") {
      return qsTrId("report_violation_type_bot");
    } else if (dialogType == "statement") {
      return qsTrId("report_violation_type_statement");
    } else if (dialogType == "text") {
      return qsTrId("report_violation_type_text")
    } else {
     return qsTrId("name");
    }
  }

  caption: qsTrId("report_violation_caption").arg(displayedDialogType)


  onReturnPressedFunction: function() {
    if (nextButton.visible && nextButton.enabled) {
      nextButton.clicked();
    }
    else if (sendButton.visible) {
      sendButton.clicked();
    }
  } //onReturnPressedFunction

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.cancelReport();
    }
  }

  initialFocusItem: ruleViolationTypeTable

  function sendRuleViolationReport() {
    if (controller != null) {
      controller.submitReport(commentTextArea.text.trim(), translationTextArea.text.trim());
    }
  }

  states: [
    State {
      name: "STEP1"
      PropertyChanges {
        target: reportDialog
        dialogStep: 1
      }
      PropertyChanges {
        target: nextButton
        enabled: ruleViolationTypeTable.selection.count > 0
        onClicked: { reportDialog.state = "STEP2"; }
      }
      PropertyChanges {
        target: ruleViolationTypeTable
        focus: true
      }
    },

    State {
      name: "STEP2"
      PropertyChanges {
        target: reportDialog
        dialogStep: 2
      }
      PropertyChanges {
        target: previousButton
        onClicked: { reportDialog.state = "STEP1"; }
      }
      PropertyChanges {
        target: nextButton
        enabled: commentTextArea.length > 0
        onClicked: { reportDialog.state = "STEP3"; }
      }
      PropertyChanges {
        target: commentTextArea
        focus: true
      }
    },

    State {
      name: "STEP3"
      PropertyChanges {
        target: reportDialog
        dialogStep: 3
      }
      PropertyChanges {
        target: previousButton
        onClicked: { reportDialog.state = "STEP2"; }
      }
      PropertyChanges {
        target: sendButton
        focus: true
      }
    }
  ]

  state: "STEP1"

  Item {
    height: 410
    width: parent.width

    ColumnLayout {
      spacing: TibiaStyle.marginRelated
      Layout.alignment: Qt.AlignTop

      anchors {
        top: parent.top;
        bottom: bottomMenuBar.top;
        bottomMargin: TibiaStyle.marginUnrelated * 2;
        left: parent.left;
        right: parent.right;
      }

      // HEADER (visible for all three steps)

      TibiaText {
        id: headerText
        property string additionalText: qsTrId("dummy_unknown")
        text: qsTrId("step_x_of_3").arg(reportDialog.dialogStep).arg(additionalText)
        Layout.fillWidth: true
        wrapMode: Text.Wrap

        states: [
          State {
            name: "STEP1"
            when: reportDialog.dialogStep == 1
            PropertyChanges {
              target: headerText;
              additionalText: qsTrId("select_violated_rule")
            }
          },
          State {
            name: "STEP2BOTNAME"
            when: reportDialog.dialogStep == 2 && reportDialog.isNameReport
            PropertyChanges {
              target: headerText
              additionalText: qsTrId("add_details_character").arg((controller != null ? controller.reportedCharacterName : qsTrId("dummy_unknown")))
            }
          },
          State {
            name: "STEP2STATEMENT"
            when: reportDialog.dialogStep == 2 && reportDialog.dialogType == "statement"
            PropertyChanges {
              target: headerText
              additionalText: qsTrId("add_details_statement")
            }
          },
          State {
            name: "STEP2TEXT"
            when: reportDialog.dialogStep == 2 && reportDialog.dialogType == "text"
            PropertyChanges {
              target: headerText
              additionalText: qsTrId("add_details_text")
            }
          },
          State {
            name: "STEP3"
            when: reportDialog.dialogStep == 3
            PropertyChanges {
              target: headerText
              additionalText: qsTrId("verify_report").arg(displayedDialogType)
            }
          }
        ] // states
      } // TibiaText

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      }

      // STEP 1 START

      TibiaTableView {
        id: ruleViolationTypeTable
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 50
        visible: reportDialog.dialogStep == 1
        model: controller != null ? controller.ruleViolationReasons : null
        KeyNavigation.tab: ruleViolationTypeTable

        TableViewColumn {}

        selection.onSelectionChanged: {
          selection.forEach(function(ModelIndex) {
            if (controller != null) {
              controller.selectReportReason(ModelIndex);
              reportReasonSummaryText.text = controller.selectedReportReasonName;
            }
          });
        }

        onActivated: {
          if (nextButton.enabled) {
            nextButton.clicked();
          }
        }
      } // TibiaTableView

      TibiaTextArea {
        id: ruleViolationTypeDescription
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 50
        readOnly: true
        visible: reportDialog.dialogStep == 1
        wrapMode: TextEdit.Wrap
        text: controller != null ? controller.selectedReportReasonDescription : ""
      }

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        text: qsTrId("select_reason")
        color: TibiaStyle.textColors["Error"]
        visible: reportDialog.dialogStep == 1
        opacity: ruleViolationTypeTable.selection.count == 0 ? 1 : 0
      }

      // STEP 2 START

      TibiaText {
        text: reportDialog.dialogType == "statement" ? qsTrId("statement_caption")
                                                     : qsTrId("text_caption")
        visible: statementTextArea.visible
      }

      TibiaTextArea {
        id: statementTextArea
        readOnly: true
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: reportDialog.dialogStep == 2 && reportDialog.isTextReport
        wrapMode: TextEdit.Wrap
        text: controller != null ? controller.reportedStatement : ""
      }

      TibiaText {
        text: qsTrId("give_translation_caption")
        visible: translationTextArea.visible
      }

      TibiaTextArea {
        id: translationTextArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: reportDialog.dialogStep == 2 &&
          (reportDialog.isTextReport || reportDialog.dialogType == "name" || reportDialog.dialogType == "hireling");
        maximumLength: 300
        wrapMode: TextEdit.Wrap
        KeyNavigation.tab: commentTextArea

        onTextChanged: {
          if (length == 1) {
            var TrimmedText = text.trim();
            cursorPosition = TrimmedText.length;
            text = TrimmedText;
          }
        }
      } // TibiaTextArea

      TibiaText {
        text: qsTrId("characters_left").arg(translationTextArea.maximumLength - translationTextArea.length)
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        visible: translationTextArea.visible
      }

      TibiaText {
        text: qsTrId("more_details_caption")
        visible: commentTextArea.visible
      }

      TibiaTextArea {
        id: commentTextArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: reportDialog.dialogStep == 2
        maximumLength: 300
        wrapMode: TextEdit.Wrap
        KeyNavigation.tab: translationTextArea.visible ? translationTextArea : commentTextArea

        onTextChanged: {
          if (length == 1) {
            var TrimmedText = text.trim();
            cursorPosition = TrimmedText.length;
            text = TrimmedText;
          }
        }
      } // TibiaTextArea

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        text: commentTextArea.length == 0 ? qsTrId("enter_comment")
          : qsTrId("characters_left").arg(commentTextArea.maximumLength - commentTextArea.length)
        color: commentTextArea.length == 0 ? TibiaStyle.textColors["Error"] : TibiaStyle.textColors["Dialog"]
        visible: reportDialog.dialogStep == 2
      }

      // STEP 3 START

      GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 2
        columnSpacing: TibiaStyle.marginUnrelated
        rowSpacing: 2
        visible: reportDialog.dialogStep == 3

        TibiaText {
          text: qsTrId("name_caption")
          Layout.alignment: Qt.AlignTop
        }

        TibiaTextField {
          Layout.fillWidth: true
          readOnly: true
          text: controller != null ? controller.reportedCharacterName : ""
        }

        TibiaText {
          text: qsTrId("reason_caption")
          Layout.alignment: Qt.AlignTop
        }

        TibiaTextField {
          id: reportReasonSummaryText
          Layout.fillWidth: true
          readOnly: true
        }

        TibiaText {
          text: reportDialog.dialogType == "statement" ? qsTrId("statement_caption")
                                                       : qsTrId("text_caption")
          Layout.alignment: Qt.AlignTop
          visible: summaryStatement.visible
        }

        TibiaTextArea {
          id: summaryStatement
          Layout.fillWidth: true
          Layout.fillHeight: true
          readOnly: true
          wrapMode: TextEdit.Wrap
          visible: reportDialog.isTextReport
          text: controller != null ? controller.reportedStatement : ""
        }

        TibiaText {
          text: qsTrId("translation_caption")
          Layout.alignment: Qt.AlignTop
          visible: summaryTranslation.visible
        }

        TibiaTextArea {
          id: summaryTranslation
          text: translationTextArea.text
          Layout.fillWidth: true
          Layout.fillHeight: true
          readOnly: true
          wrapMode: TextEdit.Wrap
          visible: reportDialog.isTextReport || reportDialog.dialogType == "name" || reportDialog.dialogType == "hireling"
        }

        TibiaText {
          text: qsTrId("comment_caption")
          Layout.alignment: Qt.AlignTop
        }

        TibiaTextArea {
          id: summaryComment
          text: commentTextArea.text
          Layout.fillWidth: true
          Layout.fillHeight: true
          readOnly: true
          wrapMode: TextEdit.Wrap
        }
      } // GridLayout
    } // ColumnLayout

    ColumnLayout {
      id: bottomMenuBar
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      Layout.alignment: Qt.AlignBottom
      spacing: TibiaStyle.marginUnrelated

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      }

      RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: TibiaStyle.marginRelated

        TibiaButton {
          id: previousButton
          text: qsTrId("previous")
          visible: reportDialog.dialogStep > 1
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        } //TibiaButton

        TibiaButton {
          id: nextButton
          text: qsTrId("next")
          visible: reportDialog.dialogStep < 3
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        } //TibiaButton

        TibiaButton {
          id: sendButton
          text: qsTrId("send")
          visible: reportDialog.dialogStep == 3
          onClicked: sendRuleViolationReport();
          KeyNavigation.tab: sendButton
        } //TibiaButton

        TibiaButton {
          text: qsTrId("cancel")
          onClicked: onCancelPressedFunction();
        } // TibiaButton
      } // RowLayout
    } // ColumnLayout
  } // Item
} // TibiaDialog
