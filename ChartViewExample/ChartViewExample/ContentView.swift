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
            Charts(data,
                   title: { Text("Title").font(.largeTitle).frame(maxHeight: .infinity, alignment: .top) },
                   //legend: {EmptyView()},
                   xAxis: xAxisInfo)
//                   xAxis: .plotValue(AxisInfo(axisValue: 0, axisEnds: (0,110),
//                                              color: .green, labelValues: [0,25,50,75,100], formatter: {value in String("\(value)") })),
//                   yAxis: .plotValue(AxisInfo(axisValue: 0, axisEnds: (0, 120),
//                                              color: .red, labelValues: [0,20,40,60,80,100], formatter: { value in String("\(value)") })),
//                   xGrid: .plotValues(GridInfo(axisValues: [20, 40, 60, 80, 100], axisEnds: (0,100), color: .yellow.opacity(0.5))),
//                   yGrid: .plotValues(GridInfo(axisValues: [25, 50, 75, 100], axisEnds: (0,100), color: .green.opacity(0.3))))

        }
            .padding()
    }
    
    func prepChartData(_ size: CGSize) -> (GraphData, AxisInfo) {
        let xRange = (0.0)...(100.0)
        let graphData = DataPoint.randomSample(10, yRange: 10...100, xScale: 10, yScale: 1)

        let canvas = PolylineGraphDatum.canvasFor(size, dataPoints: graphData,
                                                  edgeInsetRatio: EdgeInsets(top: 0.1, leading: 0.1, bottom: 0.1, trailing: 0.1))

        let polylineGraphDatum = PolylineGraphDatum(graphData, canvas: canvas)

        let xAxisInfo = AxisInfo(axisValue: 20, color: .red, gridValues: [20, 40, 60, 80, 100], gridColor: .yellow.opacity(0.5), labelValues: [0,20,40,60,80,100],
                                 labelContent: { labelValue in
            Text(String("\(labelValue)"))
                .offset(x: 0, y: -100)
                .anyView()
        })
        let yAxisInfo = AxisInfo(axisValue: 0, color: .green, gridValues: [25, 50, 75, 100], gridColor: .green.opacity(0.3), labelValues: [0,20,40,60,80,100],
                                 labelContent: { labelValue in
            Text(String("\(labelValue)"))
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
