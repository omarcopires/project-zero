import QtQuick

import qmlcomponents


Loader {
  id: root
  anchors.fill: textToDecorate != null ? textToDecorate : undefined

  property bool highlighted: false

  //from https://doc.qt.io/qt-5/qml-qtgraphicaleffects-lineargradient.html#source-prop
  //Note: It is not supported to let the effect include itself, for instance by setting source to the effect's parent.
  //meaining this component should not be a child of the text hat is been decorated
  //even so it seams to work, we better do not relay on it
  property var textToDecorate: null

  sourceComponent: {
    if (root.highlighted && textToDecorate !=null) {
      return GlobalConstants.isSoftwareRenderer ? goldGradientComponentSoftwareRenderer : goldGradientComponent;
    } else {
      return undefined;
    }
  } //sourceComponent

  Component {
    id: goldGradientComponent
    LinearGradient {
      source: textToDecorate
      start: Qt.point(0,0)
      end: Qt.point(textToDecorate.width,textToDecorate.height)
      gradient: Gradient {
        GradientStop { position: 0.0; color: "#F7AF48" }
        GradientStop { position: 0.2; color: "#F7AF48" }
        GradientStop { position: 0.5; color: "#F7EEAD" }
        GradientStop { position: 0.8; color: "#F7AF48" }
        GradientStop { position: 1.0; color: "#F7AF48" }
      } //gradient: Gradient
    } //LinearGradient
  } //Component

  Component {
    id: goldGradientComponentSoftwareRenderer
    QtObject {
      Component.onCompleted: {
        textToDecorate.color = TibiaStyle.gold1
      }

      Component.onDestruction: {
        textToDecorate.color = TibiaStyle.textColors["Dialog"]
      }
    } //QtObject
  } //Component
} //Loader
