import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0 //as GC
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA


SettingsView {
  id: root

  readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount

  ColorPicker {
    id: colorPicker

    property int systemIndex;

    dim: true
    x: parent.width/2 - width/2
    onColorAccepted: {
      GC.setSystemColorByIndex(systemIndex, t_color)
      //systemIndex = -1;
    }
    //onClosed: systemIndex = -1;
  }

  model: VisualItemModel {

    Item {
      height: root.rowHeight*4;
      width: root.rowWidth;
      Label {
        text: ZTR["Application Settings"]
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.rowHeight
      }

      Item {
        height: root.rowHeight*2 + 4
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: rowHeight
        Column {
          Item {
            id: harmonicsAsTable
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 16
              anchors.rightMargin: 16

              Label {
                textFormat: Text.PlainText
                text: ZTR["Display Harmonics as table:"]
                font.pixelSize: 20

                Layout.fillWidth: true
              }
              CheckBox {
                id: actHarmonicsAsTable
                height: parent.height
                Component.onCompleted: checked = GC.showFftAsTable
                onCheckedChanged: {
                  GC.setShowFftAsTable(checked);
                }
              }
            }
          }

          Item {
            id: decimalPlaces
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
              anchors.fill: parent
              anchors.rightMargin: 24
              anchors.leftMargin: 16

              Label {
                textFormat: Text.PlainText
                text: ZTR["Decimal places:"]
                font.pixelSize: 20

                Layout.fillWidth: true
              }

              SpinBox {
                id: actDecimalPlaces
                from: 3;
                to: 7;
                stepSize: 1
                value: GC.decimalPlaces
                onValueChanged: {
                  if(value !== GC.decimalPlaces)
                  {
                    GC.setDecimalPlaces(value)
                  }
                }

                contentItem: Label {
                  text: parent.textFromValue(parent.value, parent.locale)
                  textFormat: Text.PlainText

                  horizontalAlignment: Qt.AlignHCenter
                  verticalAlignment: Qt.AlignVCenter
                }
              }
            }
          }
          Item {
            id: systemColors
            visible: currentSession !== "com5003-ref-session.json" ///@todo replace hardcoded
            height: root.rowHeight;
            width: root.rowWidth;

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 16
              anchors.rightMargin: 16

              Label {
                textFormat: Text.PlainText
                text: ZTR["System colors:"]
                font.pixelSize: 20
              }

              ListView {
                clip: true
                Layout.fillWidth: true
                height: parent.height
                model: root.channelCount
                orientation: ListView.Horizontal
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                Rectangle {
                  color: "transparent"
                  border.color: Material.frameColor
                  anchors.fill: parent.width>parent.contentWidth ? parent.contentItem : parent;
                }
                ScrollIndicator.horizontal: ScrollIndicator {
                  onActiveChanged: active = true;
                  active: true
                }

                delegate: Item {
                  width: lChannel.contentWidth + rButton.width
                  height: root.rowHeight
                  Label {
                    id: lChannel
                    text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+1)+"Range"].ChannelName + ": "
                    font.pointSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                  }
                  Rectangle {
                    id: rButton
                    height: root.rowHeight*0.7;
                    width: height
                    radius: height
                    color: GC.systemColorByIndex(index+1)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    Label {
                      font.family: "FontAwesome"
                      font.pointSize: 12
                      text: FA.fa_pencil
                      style: Text.Outline;
                      styleColor: "black"
                      anchors.centerIn: parent
                    }
                    MouseArea {
                      anchors.fill: parent
                      onClicked: {
                        colorPicker.systemIndex = index+1
                        colorPicker.oldColor = GC.systemColorByIndex(index+1)
                        colorPicker.open()
                      }
                    }
                  }
                }
              }
              Button {
                font.family: "FontAwesome"
                font.pointSize: 12
                text: FA.fa_undo
                onClicked: {
                  GC.setDefaultColors()
                }
              }
            }
          }
        }
      }
    }

    Item {
      height: root.rowHeight*(5+sInterval.hasPeriodEntries);
      width: root.rowWidth;
      Label {
        text: ZTR["Device settings"]
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.rowHeight
      }

      Item {
        height: root.rowHeight*(4+sInterval.hasPeriodEntries) + 8
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Component {
          id: swPllAutomatic
          RowLayout {
            Label {
              textFormat: Text.PlainText
              text: ZTR["PLL channel automatic:"]
              font.pixelSize: 20

              Layout.fillWidth: true
            }

            VF.VFSwitch {
              height: parent.height
              entity: VeinEntity.getEntity("SampleModule1")
              controlPropertyName: "PAR_PllAutomaticOnOff"
            }
          }
        }

        Component {
          id: cbPllChannel
          RowLayout {
            enabled: VeinEntity.getEntity("SampleModule1").PAR_PllAutomaticOnOff === 0

            Label {
              textFormat: Text.PlainText
              text: ZTR["PLL channel:"]
              font.pixelSize: 20

              Layout.fillWidth: true
              opacity: enabled ? 1.0 : 0.4
            }

            Item {
              Layout.fillWidth: true
            }

            VF.VFComboBox {
              arrayMode: true
              entity: VeinEntity.getEntity("SampleModule1")
              controlPropertyName: "PAR_PllChannel"
              model: ModuleIntrospection.sampleIntrospection.ComponentInfo.PAR_PllChannel.Validation.Data
              centerVertical: true
              implicitWidth: root.rowWidth/4
              height: root.rowHeight

              opacity: enabled ? 1.0 : 0.4
            }
          }
        }

        Component {
          id: cbDftChannel
          RowLayout {

            Label {
              textFormat: Text.PlainText
              text: ZTR["DFT reference channel:"]
              font.pixelSize: 20

              Layout.fillWidth: true
              opacity: enabled ? 1.0 : 0.4
            }

            Item {
              Layout.fillWidth: true
            }

            VF.VFComboBox {
              arrayMode: true
              entity: VeinEntity.getEntity("DFTModule1")
              controlPropertyName: "PAR_RefChannel"
              model: ModuleIntrospection.dftIntrospection.ComponentInfo.PAR_RefChannel.Validation.Data
              centerVertical: true
              implicitWidth: root.rowWidth/4
              height: root.rowHeight

              opacity: enabled ? 1.0 : 0.4
            }
          }
        }

        Column {
          anchors.fill: parent
          spacing: 4

          Loader {
            sourceComponent: swPllAutomatic
            active: VeinEntity.hasEntity("SampleModule1")
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 16
          }

          Loader {
            sourceComponent: cbPllChannel
            active: VeinEntity.hasEntity("SampleModule1")
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 16
          }

          Loader {
            sourceComponent: cbDftChannel
            active: VeinEntity.hasEntity("DFTModule1")
            asynchronous: true

            height: active ? root.rowHeight : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 16
          }

          SettingsInterval {
            id: sInterval
            rowHeight: root.rowHeight
            rowWidth: root.rowWidth-36
            x: 20
          }
        }
      }
    }
  }
}
