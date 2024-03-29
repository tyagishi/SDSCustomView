//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/30
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import SDSCustomView



struct ContentView: View {
    var body: some View {
        GeometryReader{ geom in
            let (data, xAxisInfo) = prepChartData(geom.size)
            Charts(data, size: geom.size,
                   title: { Text("Title").font(.largeTitle).frame(maxHeight: .infinity, alignment: .top) },
                   legend: {Text("Legend").frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing).padding(.top, 50)},
                   xAxis: xAxisInfo)

        }
            .padding()
    }
    
    func prepChartData(_ size: CGSize) -> (GraphData, AxisInfo) {
        let xRange = (0.0)...(100.0)
        let graphData = DataPoint.randomSample(10, yRange: 10...100, xScale: 10, yScale: 1)

        let canvas = PolylineGraphDatum.canvasFor(size, xValueRange: 0...100, yValueRange: 0...110,
                                                  edgeInsetRatio: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))

//        let canvas = PolylineGraphDatum.canvasFor(size, dataPoints: graphData,
//                                                  edgeInsetRatio: EdgeInsets(top: 0.1, leading: 0.1, bottom: 0.1, trailing: 0.1))

        let polylineGraphDatum = PolylineGraphDatum(graphData, canvas: canvas)

        let xAxisInfo = AxisInfo(axisValue: 0, color: .red, gridValues: [20, 40, 60, 80, 100], gridColor: .red.opacity(0.5), labelValues: [20, 40, 60, 80, 100],
                                 labelContent: { labelValue in
            Text(String("\(labelValue)"))
                //.offset(x: -10, y: 0)
                .anyView()
        })
        let yAxisInfo = AxisInfo(axisValue: 0, color: .green, gridValues: [25, 50, 75, 100], gridColor: .green.opacity(0.3), labelValues: [25, 50, 75, 100],
                                 labelContent: { labelValue in
            Text(String("\(labelValue)"))
                //.offset(x: 0, y: -10)
                .anyView()
        })

        polylineGraphDatum.yAxisInfo = yAxisInfo
        return (GraphData([polylineGraphDatum], xRange: xRange), xAxisInfo)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
