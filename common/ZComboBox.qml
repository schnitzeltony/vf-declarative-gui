import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ZeraTranslation  1.0

Rectangle {
  id: root

  property bool expanded: false
  property int count : (model !==undefined) ? (arrayMode===true ? fakeModel.count : model.count) : 0;
  property int currentIndex;
  property int targetIndex;
  property string currentText;
  property string selectedText;
  property int contentRowWidth : width;
  property int contentRowHeight : height;
  property int contentMaxRows: 0
  property alias contentFlow: comboView.flow
  property real fontSize: 18;
  property bool centerVertical: false
  property real centerVerticalOffset: 0;
  //used when the displayed text should only change from external value changes
  property bool automaticIndexChange: false
  //support for QML ListModel and JS array
  property bool arrayMode: false
  property var model;

  function getMaxRows() {
    if(contentMaxRows <= 0 || contentMaxRows > count)
    {
      return count;
    }
    else
    {
      return contentMaxRows
    }
  }
  function populateFakeModel() {
    fakeModel.clear();
    if(arrayMode && model!==undefined)
    {
      for(var i=0; i<model.length; i++)
      {
        fakeModel.append({"text":model[i]})
      }
    }
  }
  function updateCurrentText() {
    if(root.arrayMode)
    {
      if(root.count> targetIndex && targetIndex >= 0)
      {
        root.currentText = fakeModel.get(targetIndex).text;
      }
    }
    else
    {
      if(root.count>0 && targetIndex >= 0)
      {
        root.currentText = root.model.get(targetIndex).text;
      }
    }
  }

  onExpandedChanged: {
    expanded ? selectionDialog.open() : selectionDialog.close()
  }
  color: Qt.darker(Material.frameColor) //buttonPressColor
  //border.color: Material.dropShadowColor
  opacity: enabled ? 1.0 : 0.5
  radius: 4
  onCountChanged: {
    updateCurrentText()
  }
  onCurrentIndexChanged: {
    targetIndex = currentIndex;
  }
  onTargetIndexChanged: {
    updateCurrentText()
    root.expanded = false
  }
  onModelChanged: {
    populateFakeModel()
    root.expanded=false
  }
  onArrayModeChanged: {
    populateFakeModel()
  }

  //List view does not support JS arrays
  ListModel {
    id: fakeModel
  }
  Item {
    anchors.fill: parent
    anchors.rightMargin: parent.width/5
    Text {
      anchors.left: parent.left
      anchors.leftMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      text:  ZTR[root.currentText] !== undefined ? ZTR[root.currentText] : root.currentText
      textFormat: Text.PlainText
      color: Material.primaryTextColor
      font.pixelSize: root.fontSize
    }
  }
  Text {
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: "▼"
    textFormat: Text.PlainText
    color: Material.primaryTextColor
    font.pixelSize: root.fontSize/2
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      if(root.enabled && root.count>0)
      {
        root.expanded=true
      }
    }
  }

  Popup {
    id: selectionDialog

    property int heightOffset: (root.centerVertical ? -popupElement.height/2 : 0) + root.centerVerticalOffset
    property int widthOffset: (root.contentMaxRows > 0) ? -(root.contentRowWidth / (1+Math.floor(root.model.length / root.contentMaxRows))) : 0

    closePolicy: Popup.CloseOnPressOutside

    onVisibleChanged: {
      root.expanded = visible
    }

    y:  -15 + heightOffset
    x: -15 + widthOffset

    Rectangle {
      id: popupElement
      width: root.contentRowWidth * Math.ceil(root.count/root.getMaxRows()) + comboView.anchors.margins*2
      height: root.contentRowHeight * root.getMaxRows() + comboView.anchors.margins*2
      color: Material.backgroundColor //used to prevent opacity leak from Material.dropShadowColor of the delegates
      Rectangle {
        anchors.fill: parent
        color: Material.dropShadowColor
        opacity: 1
        radius: 8
      }
      GridView {
        id: comboView
        anchors.fill: parent
        anchors.margins: 2

        boundsBehavior: ListView.StopAtBounds

        //adding some space here is the same as "spacing: x" is in other components
        cellHeight: root.contentRowHeight
        cellWidth: root.contentRowWidth

        flow: GridView.FlowLeftToRight

        //need to convert the array to a model
        model: (root.arrayMode===true) ? fakeModel : root.model;
        delegate: Rectangle {

          color: (root.targetIndex === index) ? Material.accent : Qt.darker(Material.frameColor) //buttonPressColor
          border.color: Material.dropShadowColor

          height: root.contentRowHeight
          width: root.contentRowWidth
          radius: 4

          MouseArea {
            anchors.fill: parent

            onClicked: {
              if(root.targetIndex !== index)
              {
                var refreshSelectedText = false;

                if(root.automaticIndexChange)
                {
                  refreshSelectedText = root.selectedText===model.text
                  root.selectedText = model.text
                }
                else
                {
                  root.targetIndex = index;
                  root.currentText = model.text;
                  refreshSelectedText = root.selectedText===root.currentText;
                  root.selectedText = root.currentText;
                }
                root.expanded = false
                if(refreshSelectedText)
                {
                  /// @DIRTYHACK: this is NOT redundant, it's an undocumented function to notify of the value change that is otherwise ignored by QML
                  root.selectedTextChanged();
                }
              }
              selectionDialog.close()
            }
          }

          Text {
            anchors.centerIn: parent
            text: ZTR[model.text] !== undefined ? ZTR[model.text] : model.text
            textFormat: Text.PlainText
            color:Material.primaryTextColor
            font.pixelSize: root.fontSize
          }
        }
      }
    }
  }
}
