import QtQuick
import QtQuick.LegacyControls


TibiaTableView {
  id: tableView
  property var permanentlyCheckbox: null
  property color permanenltyColor: "blue"

  property bool enableAutoFocusHandling: true

  property var _ignoreSelectionChanged: false

  model: null

  TableViewColumn {
    role: "name"
  } //TableViewColumn

  selection.onSelectionChanged: {
    if (_ignoreSelectionChanged) {
      return;
    }
    if(permanentlyCheckbox != null) {
      if(selection.count == 0 || model == null || model.length == 0) {
        permanentlyCheckbox.checked = false;
        _ignoreSelectionChanged = true;
        selection.clear();
        _ignoreSelectionChanged = false;
      } else {
        var selected = false;
        selection.forEach( function(rowIndex) {
          selected = model[rowIndex].permanently;
        } );
        permanentlyCheckbox.checked = selected;
      }
    }
  } //selection.onSelectionChanged

  function selectRow(rowIndex) {
    tableView.selection.clear();
    tableView.selection.select(rowIndex,rowIndex);
    tableView.currentRow = rowIndex;

    positionViewAtRow(rowIndex, ListView.Contain);
  } //rowIndex

  itemDelegate: Item {
    id: delegateRoot
    anchors.fill: parent

    TibiaText {
      id: textRepresenation
      anchors.fill: parent
      anchors.leftMargin: 2
      anchors.rightMargin: TibiaStyle.marginRelated
      elide: styleData.elideMode
      horizontalAlignment: styleData.textAlignment
      verticalAlignment: TextInput.AlignVCenter

      text: styleData.value
      color: {
        if(modelData && modelData.permanently) {
          return permanenltyColor;
        }

        return styleData.selected
                   ? TibiaStyle.textFieldSelectionTextColor
                   : TibiaStyle.textFieldTextColor
      }

      visible: !(modelData && modelData.editmodeEnabled)
    }//TibiaText

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      enabled: textRepresenation.visible

      onDoubleClicked: {
        modelData.editmodeEnabled = true;
      } //onDoubleClicked
      onClicked: {
        tableView.selectRow(styleData.row);
      } //onClicked
    } //MouseArea

    function editingFinished() {
      if(modelData) {
        modelData.name = textInputRepresentation.text;
      }
      textInputRepresentation.focus = false;
      modelData.editmodeEnabled = false;
    }


    Rectangle {
      anchors.fill: parent
      color: TibiaStyle.textFieldBackgroundColor

      visible: !textRepresenation.visible
      onVisibleChanged: {
        if(visible) {
          textInputRepresentation.forceActiveFocus();
        }
      } //onVisibleChanged

      TibiaTextInput {
        id: textInputRepresentation
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: TibiaStyle.marginRelated
        horizontalAlignment: styleData.textAlignment
        maximumLength: TibiaStyle.maxCharacterNameLength

        text: styleData.value

        onAccepted: {
          delegateRoot.editingFinished();
        } //onAccepted

        onActiveFocusChanged: {
          if(activeFocus) {
            selectAll();
          } else {
            if(modelData) {
              modelData.name = textInputRepresentation.text;
              if(tableView.enableAutoFocusHandling) {
                modelData.editmodeEnabled = false;
              }
            }
          }
        } //onActiveFocusChanged

        Keys.onDownPressed: (event) => {
          event.accepted = false;
          delegateRoot.editingFinished();
        } //Keys.onDownPressed

        Keys.onUpPressed: (event) => {
          event.accepted = false;
          delegateRoot.editingFinished();
        } //Keys.onUpPressed

      } //TibiaTextInput

      BorderImage {
        smooth: false
        anchors {left: parent.left; right: parent.right; top: parent.top}
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        source: "/images/skin/classic/horizontal-line-dark.png"
      } //Image

      BorderImage {
        smooth: false
        anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        source: "/images/skin/classic/horizontal-line-bright.png"
      } //Image
    } //Rectangle
  } //itemDelegate: Item


} //TibiaTableView
