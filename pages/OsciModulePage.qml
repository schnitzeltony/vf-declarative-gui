import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0
import ZeraGlueLogic 1.0

CCMP.ModulePage {
  id: root

  readonly property QtObject glueLogic: ZGL;
  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");
  readonly property real plotWidth: width-16;

  readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount

  //convention that channels are numbered by unit was broken, so do some $%!7 to get the right data
  readonly property var dataModels: [ZGL.OSCIP1Model, ZGL.OSCIP2Model, ZGL.OSCIP3Model, ZGL.OSCIP1Model, ZGL.OSCIP2Model, ZGL.OSCIP3Model,  ZGL.OSCIPNModel, ZGL.OSCIPNModel]

  //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
  readonly property var leftChannels: {
    var retVal = [];
    for(var channelNum=0; channelNum<channelCount; ++channelNum)
    {
      var unit = ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+parseInt(channelNum+1)].Unit;
      if(unit === "V")//UL1..UL3 +UN
      {
        retVal.push(channelNum)
      }
    }
    return retVal;
  }

  readonly property var rightChannels: {
    var retVal = [];
    for(var channelNum=0; channelNum<channelCount; ++channelNum)
    {
      var unit = ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+parseInt(channelNum+1)].Unit;
      if(unit === "A")//IL1..IL3 +IN
      {
        retVal.push(channelNum)
      }
    }
    return retVal;
  }

  ListView {
    id: lvOsci
    anchors.fill: parent
    boundsBehavior: Flickable.StopAtBounds
    model: Math.ceil(channelCount/2)
    ScrollBar.vertical: ScrollBar {
      Component.onCompleted: {
        if(QT_VERSION >= 0x050900) //policy was added after 5.7
        {
          policy = Qt.binding(function (){ return lvOsci.contentHeight > lvOsci.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff; });
        }
      }
    }

    delegate: Item {
      height: root.height/3
      width: root.plotWidth
      ChartView {
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: parent.height*1.25
        anchors.verticalCenter: parent.verticalCenter

        Label {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          rotation: -90
          text: ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+(leftChannels[index]+1)].ChannelName;
          color: GC.getColorByIndex(leftChannels[index]+1);
        }
        Label {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          rotation: 90
          text: ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+(rightChannels[index]+1)].ChannelName;
          color: GC.getColorByIndex(rightChannels[index]+1);
        }

        antialiasing: false
        backgroundColor: Material.backgroundColor
        legend.visible:false

        ValueAxis {
          id: xAxis
          min: 0
          max: 127
          labelsVisible: false
          gridVisible: true
          tickCount: 2
          minorGridVisible: false
          gridLineColor: Material.frameColor
          color: "transparent"
        }
        ValueAxis {
          id: yAxisLeft
          property real minMax: root.rangeModule["INF_Channel"+(leftChannels[index]+1)+"ActREJ"]*1.5

          min: -minMax
          max: minMax
          tickCount: 3

          minorGridLineColor: Material.dividerColor
          gridLineColor: Material.frameColor
          labelsColor: Material.primaryTextColor
          color: Material.frameColor
        }
        ValueAxis {
          id: yAxisRight
          property real minMax: root.rangeModule["INF_Channel"+(rightChannels[index]+1)+"ActREJ"]*1.5

          min: -minMax
          max: minMax
          tickCount: 3

          minorGridLineColor: Material.dividerColor
          gridLineColor: Material.frameColor
          labelsColor: Material.primaryTextColor
          color: Material.frameColor
        }

        LineSeries {
          id: leftSeries
          axisX: xAxis
          axisY: yAxisLeft
          color: GC.getColorByIndex(leftChannels[index]+1);
          width: 2
          useOpenGL: true
        }

        LineSeries {
          id: rightSeries
          axisX: xAxis
          axisYRight: yAxisRight
          color: GC.getColorByIndex(rightChannels[index]+1);
          width: 2
          useOpenGL: true
        }
        HXYModelMapper {
          model: dataModels[leftChannels[index]]
          series: leftSeries
          xRow: 0
          yRow: 1
        }
        HXYModelMapper {
          model: dataModels[rightChannels[index]]
          series: rightSeries
          xRow: 0
          yRow: 2
        }
      }
    }
  }
}
