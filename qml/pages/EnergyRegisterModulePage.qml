import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA
import "qrc:/qml/controls/error_comparison_common" as ErrorCommon
import "qrc:/qml/controls/energy_register_module" as EnergyRegister

CCMP.ModulePage {
  id: root
  clip: true

  readonly property QtObject energyRegister: VeinEntity.getEntity("SEM1Module1")
  property int status: energyRegister.ACT_Status
  readonly property alias statusHolder: stateEnum
  readonly property bool canStartMeasurement: energyRegister.PAR_StartStop !== 1

  QtObject {
    id: stateEnum
    //some of these state bits can be active in parallel

    ///doing nothing waiting to start the measurement
    readonly property int idle: 0
    ///waiting for first pulse
    readonly property int armed: 1
    ///running
    readonly property int started: 2
    ///result is available
    readonly property int ready: 4
    ///measurement was aborted
    readonly property int aborted: 8
  }

  function getStatusText(value) {
    var statusText
    switch(value)
    {
    case stateEnum.idle:
      statusText=ZTR["Idle"]
      break;
    case stateEnum.armed:
      statusText=ZTR["Armed"]
      break;
    case stateEnum.started:
      statusText=ZTR["Started"]
      break;
    case stateEnum.ready:
      statusText=ZTR["Ready"]
      break;
    case stateEnum.aborted:
      statusText=ZTR["Aborted"]
      break;
    }
    return statusText
  }


  Column {
    ErrorCommon.MeasurementView {
      measurementResult: energyRegister.ACT_Result
      progress: energyRegister.PAR_Targeted ? energyRegister.ACT_Time : 0
      progressTo: energyRegister.PAR_Targeted ? energyRegister.PAR_MeasTime : 1.0
      // do not display as long as it is not clear which's job it is to change unit
      //actualValue: GC.formatNumber(energyRegister.ACT_Energy) + " " + ModuleIntrospection.sem1Introspection.ComponentInfo.ACT_Energy.Unit
      logicalParent: root
      height: root.height*0.2
      width: root.width
    }
    Row {
      height: root.height*0.7
      width: root.width

      EnergyRegister.ParameterView {
        logicalParent: root
        width: parent.width*0.7
        height: parent.height
      }
      ErrorCommon.ErrorMarginView {
        result: root.energyRegister.ACT_Result
        width: parent.width*0.3
        height: parent.height
      }
    }
    Item {
      height: root.height*0.1
      width: root.width
      Button {
        text: ZTR["Start"]
        font.pixelSize: 20
        width: root.width/5

        enabled: root.canStartMeasurement
        highlighted: true

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
          if(energyRegister.PAR_StartStop !== 1)
          {
            energyRegister.PAR_StartStop=1;
          }
        }
      }

      Button {
        text: ZTR["Stop"]
        font.pixelSize: 20
        width: root.width/5

        enabled: root.canStartMeasurement === false

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        onClicked: {
          if(energyRegister.PAR_StartStop !== 0)
          {
            energyRegister.PAR_StartStop=0;
          }
        }
      }
    }
  }
}
