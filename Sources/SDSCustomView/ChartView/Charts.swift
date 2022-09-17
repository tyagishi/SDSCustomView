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

public typealias GraphLabel = ((CGFloat) -> any View)

public struct AxisInfo {
    let axisValue: CGFloat // for X-Axis, this is Y-Value,for Y-Axis other way around
    let gridValues: [CGFloat]
    let color: Color
    let gridColor: Color
    let labelValues: [CGFloat] // value in data coordinate (label will be appeared along axis)
    
    public init(axisValue: CGFloat,
                color: Color,
                gridValues: [CGFloat] = [], gridColor: Color = .clear,
                labelValues: [CGFloat]) {
        self.axisValue = axisValue
        self.color = color
        self.labelValues = labelValues
        self.gridValues = gridValues
        self.gridColor = gridColor
    }
}

public struct Charts<tContent: View, legendView: View, xAxisLabel: View, yAxisLabel: View>: View {
    @ObservedObject var graphData: GraphData
    let size: CGSize

    var title: tContent
    let legend: legendView

    let xAxis: AxisInfo?
    let xAxisContent: ((CGFloat) -> xAxisLabel)
    let yAxis: AxisInfo?
    let yAxisContent: ((CGFloat) -> yAxisLabel)

    public init(_ graphData: GraphData,
                @ViewBuilder title: @escaping (() -> tContent) = { EmptyView() },
                @ViewBuilder legend: @escaping (() -> legendView) = { EmptyView() },
                xAxis: AxisInfo? = nil,
                xAxisContent: @escaping ((CGFloat) -> xAxisLabel) = {_ in EmptyView()},
                yAxis: AxisInfo? = nil,
                yAxisContent: @escaping ((CGFloat) -> yAxisLabel) = {_ in EmptyView()}) {
        self.graphData = graphData
        self.title = title()
        self.legend = legend()
        self.xAxis = xAxis
        self.xAxisContent = xAxisContent
        self.yAxis = yAxis
        self.yAxisContent = yAxisContent

        self.size = graphData.graphDatum.first?.canvas.canvasSize ?? CGSize(width: 100, height: 100)
    }
    
    public var body: some View {
        ZStack {
            title
            legend
            if let datum = graphData.graphDatum.first,
               let info = xAxis {
                XAxisView(canvas: datum.canvas, axisInfo: info,
                          labelContent: xAxisContent)
            }
            ForEach(graphData.graphDatum) { datum in
                PolylineView(datum, canvas: datum.canvas,// yAxis: yAxis,
                             yAxisContent: yAxisContent)
            }
        }
        .frame(size)
    }
}


public struct XAxisView<lContent: View>: View {
    public typealias LabelGen = ((CGFloat) -> lContent)
    let canvas: SDSCanvas
    let axisInfo: AxisInfo
    let labelContent: LabelGen

    public init(canvas: SDSCanvas,
                axisInfo: AxisInfo,
                labelContent: @escaping LabelGen) {
        self.canvas = canvas
        self.axisInfo = axisInfo
        self.labelContent = labelContent
    }

    public var body: some View {
        ZStack {
            let axisStart = canvas.locOnCanvas(CGPoint(x: 0.0, y: axisInfo.axisValue))
            Path { context in
                context.move(to: CGPoint(x: 0, y: axisStart.y))
                context.addLine(to: CGPoint(x: canvas.canvasSize.width, y: axisStart.y))
            }
            .stroke(lineWidth: 1.0)
            .fill(axisInfo.color)
            ForEach(axisInfo.gridValues, id: \.self) { gridValue in
                let gridPoint = canvas.locOnCanvas(CGPoint(x: 0.0, y: gridValue))
                Path { context in
                    context.move(to: CGPoint(x: 0, y: gridPoint.y))
                    context.addLine(to: CGPoint(x: canvas.canvasWidth, y: gridPoint.y))
                }
                .stroke(lineWidth: 0.5)
                .fill(axisInfo.gridColor)
            }

            ForEach(axisInfo.labelValues, id: \.self) { value in
                labelContent(value)
                    .position(canvas.locOnCanvas(.init(x: value, y: axisInfo.axisValue)))
                    .font(.footnote)
            }

        }
    }
}
public struct YAxisView<lContent: View>: View {
    public typealias LabelGen = ((CGFloat) -> lContent)
    let canvas: SDSCanvas
    let axisInfo: AxisInfo
    let labelContent: LabelGen

    @State private var offset = CGSize.zero

    public init(canvas: SDSCanvas, axisInfo: AxisInfo,
                labelContent: @escaping LabelGen) {
        self.canvas = canvas
        self.axisInfo = axisInfo
        self.labelContent = labelContent
    }

    public var body: some View {
        ZStack {
            let axisStart = canvas.locOnCanvas(CGPoint(x: axisInfo.axisValue, y: 0))
            Path { context in
                context.move(to: CGPoint(x: axisStart.x, y: 0))
                context.addLine(to: CGPoint(x: axisStart.x, y: canvas.canvasHeight))
            }
            .stroke(lineWidth: 1.0)
            .fill(axisInfo.color)
            ForEach(axisInfo.gridValues, id: \.self) { gridValue in
                let gridPoint = canvas.locOnCanvas(CGPoint(x: gridValue, y: 0))
                Path { context in
                    context.move(to: CGPoint(x: gridPoint.x, y: 0))
                    context.addLine(to: CGPoint(x: gridPoint.x, y: canvas.canvasHeight))
                }
                .stroke(lineWidth: 0.5)
                .fill(axisInfo.gridColor)
            }
            ForEach(axisInfo.labelValues, id: \.self) { value in
                labelContent(value)
                    .position(canvas.locOnCanvas(.init(x: axisInfo.axisValue, y: value)).move(offset.width * -2.2, offset.height * 0))
                    .font(.footnote)
            }
        }
            
    }
}

struct PolylineView<yAxisLabel: View>: View {
    @ObservedObject var datum:PolylineGraphDatum
    let canvas: SDSCanvas
    let yAxisContent: ((CGFloat) -> yAxisLabel)

    init(_ datum: PolylineGraphDatum, canvas: SDSCanvas,
         yAxisContent: @escaping ((CGFloat) -> yAxisLabel)) {
        self.datum = datum
        self.canvas = canvas
        self.yAxisContent = yAxisContent
    }
    
    var body: some View {
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

//                    ForEach(datum.dataPoints) { data in
//                        datum.vertexSymbol
//                            .position(canvas.locOnCanvas(data.loc))
//                            .foregroundColor(datum.lineColor)
//                        Text(datum.valueLabelFormatter(data.loc))
//                            .help(datum.tooltipFormatter(data.loc))
//                            .position(canvas.locOnCanvas(data.loc).move(datum.labelOffset))
//                            .foregroundColor(datum.lineColor)
//                            .font(.footnote)
//                    }
            } else {
                Text("No data for graph")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            if let info = datum.yAxisInfo {
                YAxisView(canvas: canvas , axisInfo: info,
                          labelContent: { value in
                    yAxisContent(value)
                })
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


