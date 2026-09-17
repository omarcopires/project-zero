import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls
import qmlenumvalues

Item {
  id: root
  
  property var rewardType: TaskboardRewardListModel.Object
  property int appearanceId: 0
  property int optionalAppearanceId: 0
  property int outfitAppearanceId: 0
  property var headColor: "black"
  property var torsoColor: "black"
  property var legsColor: "black"
  property var detailColor: "black"
  property bool addOn1: false
  property bool addOn2: false

  implicitHeight: TibiaStyle.mapWindowPixelPerField * 2
  implicitWidth: TibiaStyle.mapWindowPixelPerField * 2
  
  TibiaFrame1PixelDown {
      
    id: frame
    height: TibiaStyle.mapWindowPixelPerField * 2
    width: TibiaStyle.mapWindowPixelPerField * 2
    anchors.centerIn: parent
    
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
  
    
      Loader {
             
        anchors.centerIn: parent
        
        Component {
          id: singleObjectComponent
          
          SingleObjectAppearanceInstanceRenderer {
            id: appearanceInstanceViewer
            anchors.centerIn: parent
            width: TibiaStyle.mapWindowPixelPerField
            height: TibiaStyle.mapWindowPixelPerField
          
            animated: true
            typeid: root.appearanceId
            cumulativeCount: 0
            liquidType: ObjectAppearanceInstance.EMPTY
            hookDirection: ObjectAppearanceInstance.NONE
            
          } //SingleObjectAppearanceInstanceRenderer
          
        } // Component
        
        Component {
          id: outfitComponent
          
          OutfitAppearanceInstanceRenderer {
            id: appearanceInstanceRenderer
            anchors.fill: parent
          
            animated: true
            outfitId: root.outfitAppearanceId
            headColor: root.headColor
            torsoColor: root.torsoColor
            legsColor: root.legsColor
            detailColor: root.detailColor
            firstAddOn: root.addOn1
            secondAddOn: root.addOn2
          } //OutfitAppearanceInstanceRenderer
          
        } // Component
  
        
        Component {
          id: bedComponent
          
          
          AppearanceInstanceRenderer {
              id: bedItemRenderer
              anchors.fill: parent
              //anchors.margins: parent.borderWidth
  
              smoothTextureFiltering: false
              center: true
              animated: true
  
              Component {
                id: objectComponent
  
                ObjectAppearanceInstance {
                  position: Qt.point(0, 0)
                }
              } // Component
  
              Component.onCompleted: {
                var headBoardApperanceInstance = objectComponent.createObject(bedItemRenderer);
                headBoardApperanceInstance.typeid = root.appearanceId;
                headBoardApperanceInstance.hookDirection = ObjectAppearanceInstance.SOUTH;
                
                var footBoardApperanceInstance = objectComponent.createObject(bedItemRenderer);
                footBoardApperanceInstance.typeid = root.optionalAppearanceId;
                footBoardApperanceInstance.hookDirection = ObjectAppearanceInstance.SOUTH;
                footBoardApperanceInstance.position = Qt.point(0, 32);
                
                bedItemRenderer.appearanceInstances = [headBoardApperanceInstance, footBoardApperanceInstance];
              }
            } // AppearanceInstanceRenderer
          
          
        } // Component

        Component {
          id: promotionPointComponent
          Image {

            width: TibiaStyle.mapWindowPixelPerField
            height: TibiaStyle.mapWindowPixelPerField

            source: "/images/taskboard/icon_tasksystem_promotionpoint.png"

          } // Image
        } // Component
      
        
        sourceComponent: (root.rewardType == TaskboardRewardListModel.Object) ? singleObjectComponent : 
          (root.rewardType == TaskboardRewardListModel.Outfit || root.rewardType == TaskboardRewardListModel.Mount) ? outfitComponent : 
           (root.rewardType == TaskboardRewardListModel.Bed) ? bedComponent : 
           (root.rewardType == TaskboardRewardListModel.PromotionPoint) ? promotionPointComponent : 
           undefined
        
      } // Loader
  
    } //Image
  } //TibiaFrame1PixelDown
  
} // Item
