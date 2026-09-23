import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

RowLayout {

  property string upperPanelCaption: ""
  property string lowerLeftPanelCaption: ""
  property string lowerRightPanelCaption: ""
  property string rightPanelUpperCaption: ""

  property Component upperPanelLeftComponent: null
  property Component upperPanelRightComponent: null
  property Component lowerLeftPanelComponent: null
  property Component lowerRightPanelComponent: null
  property Component rightPanelUpperComponent: null
  property Component rightPanelLowerComponent: null

  ColumnLayout {
    TibiaPanelWithCaption {
      collapsible: false
      expanded: true
      Layout.fillWidth: true
      caption: upperPanelCaption

      contentDelegate: RowLayout {
        Loader {
          id: upperPanelLeftComponentLoader
          Layout.minimumHeight: parent.height
          Layout.preferredWidth: lowerLeftPanel.contentItem.width
          sourceComponent: upperPanelLeftComponent
        }
        ColumnLayout {
          Layout.minimumHeight: parent.height
          Loader {
            Layout.fillWidth: true
            sourceComponent: upperPanelRightComponent
          }
        }
      }

    }
    RowLayout {
      Layout.fillWidth: true
      TibiaPanelWithCaption {
        id: lowerLeftPanel
        collapsible: false
        expanded: true
        Layout.preferredWidth: 142
        caption: lowerLeftPanelCaption
        fillHeight: true
        contentDelegate: ColumnLayout {
          Loader {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            sourceComponent: lowerLeftPanelComponent
          }
        }
      }
      TibiaPanelWithCaption {
        id: lowerRightPanel
        collapsible: false
        expanded: true
        useWidthFromContentItem: true
        caption: lowerRightPanelCaption
        contentDelegate: ColumnLayout {
          Loader {
            sourceComponent: lowerRightPanelComponent
          }
        }
      }
    }
  }

  ColumnLayout {
    Layout.maximumWidth: 240
    Layout.minimumHeight: parent.height
    TibiaPanelWithCaption {
      collapsible: false
      expanded: true
      caption: rightPanelUpperCaption
      Layout.fillWidth: true
      contentDelegate: ColumnLayout {
        Loader {
          Layout.fillWidth: true
          sourceComponent: rightPanelUpperComponent
        }
      }
    }
    Loader {
      Layout.preferredWidth: 240
      Layout.fillHeight: true
      sourceComponent: rightPanelLowerComponent
    }
  }

}
