//
//  Charts.swift
//
//  Created by : Tomoaki Yagishita on 2021/09/16
//  © 2021  SmallDeskSoftware
//

import SwiftUI
import SDSCGExtension
import SDSViewExtension
import SwiftUIDebugUtil


public struct ChartsPushOut: View{
    @ObservedObject var graphData: GraphData
//    var title: (() -> tContent)
//    let size: CGSize
//    let legend: (() -> legendView)
    
    public init(_ graphData: GraphData) {
//                @ViewBuilder title: @escaping () -> tContent,
//                @ViewBuilder legend: @escaping () -> legendView) {
        self.graphData = graphData
//        self.title =
//        self.legend = legend
    }
    
    public var body: some View {
        GeometryReader { geom in
            Charts(graphData, title: {Text("Title")}, legend: {EmptyView().anyView()})
        }
    }
}

public struct Charts<tContent: View, legendView: View>: View {
    @ObservedObject var graphData: GraphData
    var title: tContent
    let legend: legendView
    
    public init(_ graphData: GraphData,
                @ViewBuilder title: () -> tContent,
                @ViewBuilder legend: () -> legendView) {
        self.graphData = graphData
        self.title = title()
        self.legend = legend()
    }
    
    public var body: some View {
        ZStack {
            title
            legend
            ForEach(graphData.graphDatum) { datum in
                PolylineView(datum, canvas: datum.canvas)
            }
        }
    }
}


struct XAxisView: View {
    let canvas: SDSCanvas
    let labelValues: [CGFloat]
    let xFormatter: ((CGFloat)->String)
    var body: some View {
        ZStack {
            Path { context in
                context.move(to: canvas.invertedY(point:CGPoint(x: xAxisXStart, y: xAxisY)))
                context.addLine(to: canvas.invertedY(point: CGPoint(x: xAxisXEnd, y: xAxisY)))
            }
            .stroke(lineWidth: 1.0)
            ForEach(labelValues, id: \.self) { value in
                Text(xFormatter(value))
                    .position(x: canvas.invertedY(point:canvas.locOnCanvas(.init(x: value, y: canvas.llValueY))).x,
                              y: canvas.canvasHeight/2.0)
                    .font(.footnote)
            }
        }
    }
    var xAxisXStart: CGFloat {
        return 0
    }
    var xAxisXEnd: CGFloat {
        return canvas.canvasWidth
    }
    var xAxisY: CGFloat {
        return canvas.llValueY * -1 * canvas.yScale
    }
}
struct YAxisView: View {
    let canvas: SDSCanvas
    var body: some View {
        Path { context in
            context.move(to: canvas.invertedY(point: CGPoint(x: yAxisX, y: yAxisYStart)))
            context.addLine(to: canvas.invertedY(point: CGPoint(x: yAxisX, y: yAxisYEnd)))
        }
        .stroke(lineWidth: 1.0)
    }
    var yAxisYStart: CGFloat {
        return 0
    }
    var yAxisYEnd: CGFloat {
        return canvas.canvasHeight
    }
    var yAxisX: CGFloat {
        return canvas.llValueX * -1 * canvas.xScale
    }
}

struct PolylineView: View {
    @ObservedObject var datum:PolylineGraphDatum
    let canvas: SDSCanvas
    
    init(_ datum: PolylineGraphDatum, canvas: SDSCanvas) {
        self.datum = datum
        self.canvas = canvas
    }
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
                // data path
                if datum.dataSetForGraph.count > 0 {
                    Path { path in
                        path.move(to: canvas.locOnCanvas(datum.dataSetForGraph[0].loc))
                        //datum.vertexSymbol
                            //.position(locOnCanvas(datum.dataSetForGraph[0].loc)
                        for index in 1..<datum.dataSetForGraph.count {
                            path.addLine(to: canvas.locOnCanvas(datum.dataSetForGraph[index].loc))
                        }
                    }
                    .stroke(lineWidth: 3.0)
                    .fill(datum.lineColor)
                    .clipped()
                    ForEach(datum.dataPoints) { data in
                        datum.vertexSymbol
                            .position(canvas.locOnCanvas(data.loc))
                            .foregroundColor(datum.lineColor)
                        Text("\(data.loc.y, specifier: "%.1f")")
                            .position(canvas.locOnCanvas(data.loc).move(datum.labelOffset))
                        .font(.footnote)

                    }
                    XAxisView(canvas: canvas,labelValues: datum.labelXValus, xFormatter: datum.labelXFormatter)
                    //YAxisView(canvas: canvas)
                } else {
                    Text("No data for graph")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }
}

extension CGPoint {
    func within(_ size: CGSize) -> Bool {
        return (0 < self.x ) && (self.x < size.width) && (0 < self.y) && (self.y < size.height)
    }
}

extension CGRect {
    var lowerRightCoord: CGPoint {
        return CGPoint(x: self.size.width, y: self.size.height)
    }
    var lowerLeftCoord: CGPoint {
        return CGPoint(x: self.originX * -1, y: self.originY * -1)
    }
    var upperRightCoord: CGPoint {
        return CGPoint(x: self.size.width, y: self.size.height)
    }
    var upperLeftCoord: CGPoint {
        return CGPoint(x: self.originX * -1, y: self.originY * -1)
    }
}


