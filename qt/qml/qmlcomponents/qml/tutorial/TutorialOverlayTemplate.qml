import QtQuick
import QtQuick.Layouts

import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: baseplate

  property alias htmlText: textElement.text
  property alias caption: captionElement.text
  property alias showBorder: borderItem.visible
  property alias textHintRectangle: textHintRectangle.anchors
  property int textHintRectangleBorderOffset: showBorder ? TibiaStyle.tutorialTextHintWithMarkerVisibleOffset : TibiaStyle.tutorialTextHintStandardOffset
  property alias textAnchor: textHintRectangle.state
  property bool textHintVisible: htmlText != "" ? true : false

  Rectangle {
    id: borderItem
    visible: true
    anchors.fill: parent
    anchors.margins: -1 * TibiaStyle.tutorialMarkerBorderMargins
    color: "transparent"
    border.width: TibiaStyle.tutorialMarkerBorderWidth
    border.color: TibiaStyle.tutorialMarkerColor
    radius: TibiaStyle.tutorialMarkerCornerRadius
  }
  SequentialAnimation {
    running: borderItem.visible
    loops: Animation.Infinite
    NumberAnimation {
      target: borderItem
      property: "opacity"
      to: 0.0
      duration: 500
    }
    NumberAnimation {
      target: borderItem
      property: "opacity"
      to: 1.0
      duration: 500
    }
  }

  TibiaRadiusedSemiTranspartentRectangle {

    id: textHintRectangle
    z: 9999
    color: TibiaStyle.tutorialBackgroundColor

    width: textElement.width + 2 * TibiaStyle.lenshelpContentMargin
    height: contentLayout.height + 2 * TibiaStyle.lenshelpContentMargin
    state: "topCenter"
    visible: textHintVisible

    states: [
      State {
        name: "topLeft"
        AnchorChanges {
          target: textHintRectangle
          anchors.bottom: baseplate.top
          anchors.left: baseplate.left
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.bottomMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "topCenter"
        AnchorChanges {
          target: textHintRectangle
          anchors.bottom: baseplate.top
          anchors.horizontalCenter: baseplate.horizontalCenter
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.bottomMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "topRight"
        AnchorChanges {
          target: textHintRectangle
          anchors.bottom: baseplate.top
          anchors.right: baseplate.right
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.bottomMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "bottomLeft"
        AnchorChanges {
          target: textHintRectangle
          anchors.top: baseplate.bottom
          anchors.left: baseplate.left
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.topMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "bottomCenter"
        AnchorChanges {
          target: textHintRectangle
          anchors.top: baseplate.bottom
          anchors.horizontalCenter: baseplate.horizontalCenter
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.topMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "bottomRight"
        AnchorChanges {
          target: textHintRectangle
          anchors.top: baseplate.bottom
          anchors.right: baseplate.right
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.topMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "leftBottom"
        AnchorChanges {
          target: textHintRectangle
          anchors.right: baseplate.left
          anchors.bottom: baseplate.bottom
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.rightMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "leftCenter"
        AnchorChanges {
          target: textHintRectangle
          anchors.right: baseplate.left
          anchors.verticalCenter: baseplate.verticalCenter
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.rightMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "leftTop"
        AnchorChanges {
          target: textHintRectangle
          anchors.right: baseplate.left
          anchors.top: baseplate.top
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.rightMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "rightBottom"
        AnchorChanges {
          target: textHintRectangle
          anchors.left: baseplate.right
          anchors.bottom: baseplate.bottom
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.leftMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "rightCenter"
        AnchorChanges {
          target: textHintRectangle
          anchors.left: baseplate.right
          anchors.verticalCenter: baseplate.verticalCenter
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.leftMargin: textHintRectangleBorderOffset
        }
      }
      , State {
        name: "rightTop"
        AnchorChanges {
          target: textHintRectangle
          anchors.left: baseplate.right
          anchors.top: baseplate.top
        }
        PropertyChanges {
          target: textHintRectangle
          anchors.leftMargin: textHintRectangleBorderOffset
        }
      }
    ]

    ColumnLayout {
      id: contentLayout
      anchors {left: parent.left; top: parent.top; right: parent.right}
      anchors.margins: TibiaStyle.lenshelpContentMargin

      spacing: TibiaStyle.marginRelated

      TibiaText {
        id: captionElement
        style: Text.Outline
        styleColor: TibiaStyle.lenshelpCaptionOutlineColor
        styleType: "LenshelpCaption"

        text: "Caption"
      } //TibiaText

      TibiaText {
        id: textElement
        style: Text.Outline
        styleColor: TibiaStyle.lenshelpCaptionOutlineColor
        wrapMode: Text.Wrap
        textFormat: Text.RichText //Text.StyledText this fixes the align middle for images
        styleType: "LenshelpContent"

        text: "Content"

        lineHeight: 1.1
      } //TibiaText

    } //ColumnLayout
  } // TibiaRadiusedSemiTranspartentRectangle



}

