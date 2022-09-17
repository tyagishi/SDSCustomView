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
            Charts(prepChartData(geom.size),
                   title: { Text("Title").font(.largeTitle).frame(maxHeight: .infinity, alignment: .top) },
                   legend: {EmptyView()},
                   xAxis: .plotValue(AxisInfo(axisValue: 0, axisEnds: (0,110),
                                              color: .green, labelValues: [0,25,50,75,100], formatter: {value in String("\(value)") })),
                   yAxis: .plotValue(AxisInfo(axisValue: 0, axisEnds: (0, 120),
                                              color: .red, labelValues: [0,20,40,60,80,100], formatter: { value in String("\(value)") })),
                   xGrid: .plotValues(GridInfo(axisValues: [20, 40, 60, 80, 100], axisEnds: (0,100), color: .yellow.opacity(0.5))),
                   yGrid: .plotValues(GridInfo(axisValues: [25, 50, 75, 100], axisEnds: (0,100), color: .green.opacity(0.3))))

        }
            .padding()
    }
    
    func prepChartData(_ canvasSize: CGSize) -> GraphData {
        let xRange = (0.0)...(100.0)
        let graphData = DataPoint.randomSample(10, yRange: 10...100, xScale: 10, yScale: 1)

        let polylineGraphDatum = PolylineGraphDatum(graphData, color: .red, vertexSymbol: {EmptyView().anyView()},
                                                    xValueRange: (-20)...(120), yValueRange: -10...120, size: canvasSize)
        
        return GraphData([polylineGraphDatum], xRange: xRange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
