import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import SortFilterProxyModel 0.2
import "qrc:/data/staticdata/FontAwesome.js" as FA

Popup {
  id: root

  readonly property QtObject dataLogger: VeinEntity.getEntity("_LoggingSystem")
  readonly property var loggedComponents: VeinEntity.getEntity("_System").LoggedComponents

  function initModels() {
    availModel.clear();
    selectedModel.clear();

    var entityIntrospection = ModuleIntrospection.introMap;
    for(var entityName in entityIntrospection)
    {
      var tmpEntity = VeinEntity.getEntity(entityName);
      var tmpEntityId = tmpEntity.entityId();
      var disallowedComponents = ["EntityName", "INF_ModuleInterface"];
      var alreadySelected = loggedComponents[tmpEntityId];

      for(var i = 0; i< tmpEntity.keys().length; ++i)
      {
        var tmpComponentName = tmpEntity.keys()[i];
        var componentIntrospection = entityIntrospection[entityName];

        if(alreadySelected !== undefined && alreadySelected.indexOf(tmpComponentName) > -1)
        {
          selectedModel.append({
                                 "entId": tmpEntityId,
                                 "entName": entityName,
                                 "compName": tmpComponentName,
                                 "compDescription": componentIntrospection.ComponentInfo[tmpComponentName].Description,
                                 "compUnit": componentIntrospection.ComponentInfo[tmpComponentName].Unit,
                               });
        }
        else if(disallowedComponents.indexOf(tmpComponentName) < 0)
        {
          availModel.append({
                              "entId": tmpEntityId,
                              "entName": entityName,
                              "compName": tmpComponentName,
                              "compDescription": componentIntrospection.ComponentInfo[tmpComponentName].Description,
                              "compUnit": componentIntrospection.ComponentInfo[tmpComponentName].Unit,
                            });
        }
      }
    }
  }

  Component.onCompleted: {
    initModels();
  }

  readonly property var currentItem: (availView.currentItem !== undefined && availView.currentItem !== null
                                      ? availModel.get(filteredAvailModel.mapToSource(availView.currentIndex))
                                      : (selectedView.currentItem !== undefined && selectedView.currentItem !== null
                                         ? selectedModel.get(filteredSelectedModel.mapToSource(selectedView.currentIndex))
                                         : undefined));

  ListModel {
    id: availModel
  }
  SortFilterProxyModel {
    id: filteredAvailModel
    sourceModel: availModel
    sorters: [
      RoleSorter { roleName: "entName"; },
      RoleSorter { roleName: "compName" }
    ]

    filters: [
      RegExpFilter {
        roleName: "compName"
        pattern: availSearchField.text
        caseSensitivity: Qt.CaseInsensitive
      }
    ]
  }

  ListModel {
    id: selectedModel
  }
  SortFilterProxyModel {
    id: filteredSelectedModel
    sourceModel: selectedModel
    sorters: [
      RoleSorter { roleName: "entName"; },
      RoleSorter { roleName: "compName" }
    ]

    filters: [
      RegExpFilter {
        roleName: "compName"
        pattern: selectedSearchField.text
        caseSensitivity: Qt.CaseInsensitive
      }
    ]
  }

  Component {
    id: selectableItemDelegate
    ItemDelegate {
      width: parent.width-8 //don't overlap with the ScrollIndicator
      height: 32
      highlighted: ListView.isCurrentItem
      onClicked: {
        ListView.view.currentIndex = index
      }
      Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4
        spacing: 10
        Label { text: compName; }
      }
    }
  }
  Component {
    id: sectionHeading
    Rectangle {
      color: Material.accentColor
      width: parent.width-8 //don't overlap with the ScrollIndicator
      implicitHeight: childrenRect.height

      Label {
        text: section
        font.bold: true
        font.pixelSize: 20
        x: 4
      }
    }
  }

  TextField {
    id: availSearchField
    placeholderText: "Regex search"
    selectByMouse: true
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: middleFrame.left
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    Component.onCompleted: forceActiveFocus()
    enabled: availView.moving===false
  }
  Label {
    anchors.bottom: availSearchField.top
    anchors.horizontalCenter: availSearchField.horizontalCenter
    font.pointSize: 10
    text: "Available for recording"
  }

  ListView {
    id: availView
    model: filteredAvailModel
    delegate: selectableItemDelegate
    anchors.left: parent.left
    anchors.right: middleFrame.left
    anchors.top: availSearchField.bottom
    anchors.bottom: buttonContainer.top
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    section.property: "entName"
    section.criteria: ViewSection.FullString
    section.delegate: sectionHeading
    clip: true

    currentIndex: -1
    onCurrentItemChanged: {
      if(currentIndex !== -1)
      {
        availSearchField.focus=true;
        selectedView.currentIndex = -1;
      }
    }
    ScrollIndicator.vertical: ScrollIndicator {
      width: 8
      active: true
      onActiveChanged: {
        if(active !== true)
        {
          active = true;
        }
      }
    }
  }
  TextField {
    id: selectedSearchField
    placeholderText: "Regex search"
    selectByMouse: true
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: middleFrame.right
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    enabled: selectedView.moving===false
  }
  Label {
    anchors.bottom: selectedSearchField.top
    anchors.horizontalCenter: selectedSearchField.horizontalCenter
    font.pointSize: 10
    text: "Selected for recording"
  }
  ListView {
    id: selectedView
    model: filteredSelectedModel
    delegate: selectableItemDelegate
    anchors.left: middleFrame.right
    anchors.right: parent.right
    anchors.top: selectedSearchField.bottom
    anchors.bottom: buttonContainer.top
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    section.property: "entName"
    section.criteria: ViewSection.FullString
    section.delegate: sectionHeading
    clip: true

    currentIndex: -1
    onCurrentItemChanged: {
      if(currentIndex !== -1)
      {
        selectedSearchField.focus=true;
        availView.currentIndex = -1;
      }
    }
    ScrollIndicator.vertical: ScrollIndicator {
      width: 8
      active: true
      onActiveChanged: {
        if(active !== true)
        {
          active = true;
        }
      }
    }
  }
  Frame {
    id: middleFrame
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: buttonContainer.top
    implicitWidth: Math.floor(root.width/4)


    Column {
      anchors.fill: parent

      Label {
        text: "Description:"
        font.bold: true
        anchors.left: parent.left
        anchors.right: parent.right
        visible: descriptionLabel.text !== ""
      }
      Label {
        id: descriptionLabel
        text: root.currentItem ? root.currentItem.compDescription : ""
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
      }
      Item {
        //spacer
        height: 8
        width: parent.width
      }
      Label {
        text: "Unit:"
        font.bold: true
        anchors.left: parent.left
        anchors.right: parent.right
        visible: unitLabel.text !== ""
      }
      Label {
        id: unitLabel
        text: root.currentItem ? root.currentItem.compUnit : ""
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
        visible: text !== ""
      }
      Item {
        //spacer
        height: 8
        width: parent.width
      }
      Label {
        text: "Actual value:"
        font.bold: true
        anchors.left: parent.left
        anchors.right: parent.right
        visible: valueLabel.text !== ""
      }
      Label {
        id: valueLabel
        readonly property var compValue: root.currentItem ? VeinEntity.getEntity(root.currentItem.entName)[root.currentItem.compName] : ""
        text: root.currentItem ? compValue.toString() : ""
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WrapAnywhere
        elide: Text.ElideRight
        maximumLineCount: 3
        height: 200
        visible: text !== ""
      }
    }

    Button {
      visible: availView.currentIndex !== -1;
      onVisibleChanged: focus=false;
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      text: FA.fa_long_arrow_right
      font.family: "FontAwesome"
      font.pixelSize: 32
      focusPolicy: Qt.NoFocus //prevent stealing the focus from search field

      onClicked: {
        var proxyIndex = filteredAvailModel.mapToSource(availView.currentIndex);
        var toMove = availModel.get(proxyIndex);
        selectedModel.append(toMove);
        availModel.remove(proxyIndex);
      }
    }
    Button {
      visible: selectedView.currentIndex !== -1;
      onVisibleChanged: focus=false;
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      text: FA.fa_long_arrow_left
      font.family: "FontAwesome"
      font.pixelSize: 32
      focusPolicy: Qt.NoFocus //prevent stealing the focus from search field

      onClicked: {
        var proxyIndex = filteredSelectedModel.mapToSource(selectedView.currentIndex);
        var toMove = selectedModel.get(proxyIndex);
        availModel.append(toMove);
        selectedModel.remove(proxyIndex);
      }
    }
  }

  Item {
    id: buttonContainer
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.height/10

    Button {
      id: acceptButton
      text: "Accept"
      font.pixelSize: 20
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      width: root.width/4
      highlighted: true
      onClicked: {
        var componentsToLog = {};
        for(var i=0; i<selectedModel.count; ++i)
        {
          var tmpObj = selectedModel.get(i);
          var tmpArray = [];
          if(componentsToLog[tmpObj.entId] !== undefined)
          {
            tmpArray = componentsToLog[tmpObj.entId];
          }
          tmpArray.push(tmpObj.compName);
          componentsToLog[tmpObj.entId] = tmpArray;
        }
        VeinEntity.getEntity("_System").LoggedComponents = componentsToLog;
        root.close();
      }
    }

    Button {
      id: resetButton
      text: "Close"
      font.pixelSize: 20
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      anchors.right: parent.right
      width: root.width/4
      onClicked: {
        if(availView.moving === false && selectedView.moving === false)
        {
          availView.currentIndex=-1;
          selectedView.currentIndex=-1;
          initModels();
          root.close();
        }
      }
    }
  }
}
