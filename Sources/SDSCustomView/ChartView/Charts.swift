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
    public typealias AxisLabelGen = ((CGFloat) -> AnyView)
    let axisValue: CGFloat // for X-Axis, this is Y-Value,for Y-Axis other way around
    let gridValues: [CGFloat]
    let color: Color
    let gridColor: Color
    let labelValues: [CGFloat] // value in data coordinate (label will be appeared along axis)
    let labelContent: AxisInfo.AxisLabelGen

    public init(axisValue: CGFloat, color: Color,
                gridValues: [CGFloat] = [], gridColor: Color = .clear,
                labelValues: [CGFloat], labelContent: @escaping AxisInfo.AxisLabelGen = { _ in EmptyView().anyView() } ) {
        self.axisValue = axisValue
        self.color = color
        self.gridValues = gridValues
        self.gridColor = gridColor
        self.labelValues = labelValues
        self.labelContent = labelContent
    }
}

public struct Charts<tContent: View, legendView: View>: View {
    @ObservedObject var graphData: GraphData
    let size: CGSize

    var title: tContent
    let legend: legendView

    let xAxis: AxisInfo?

    public init(_ graphData: GraphData,
                @ViewBuilder title: @escaping (() -> tContent) = { EmptyView() },
                @ViewBuilder legend: @escaping (() -> legendView) = { EmptyView() },
                xAxis: AxisInfo? = nil ) {
        self.graphData = graphData
        self.title = title()
        self.legend = legend()
        self.xAxis = xAxis

        self.size = graphData.graphDatum.first?.canvas.canvasSize ?? CGSize(width: 100, height: 100)
    }
    
    public var body: some View {
        ZStack {
            title
            legend
            if let datum = graphData.graphDatum.first,
               let info = xAxis {
                XAxisView(canvas: datum.canvas, axisInfo: info,
                          labelContent: info.labelContent)
            }
            ForEach(graphData.graphDatum) { datum in
                PolylineView(datum, canvas: datum.canvas)
            }
        }
        .frame(size)
    }
}


public struct XAxisView: View {
    public typealias LabelGen = ((CGFloat) -> AnyView)
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
            let axisPoint = canvas.locOnCanvas(CGPoint(x: 0.0, y: axisInfo.axisValue))
            // MARK: Axis
            Path { context in
                context.move(to: CGPoint(x: 0, y: axisPoint.y))
                context.addLine(to: CGPoint(x: canvas.canvasSize.width, y: axisPoint.y))
            }
            .stroke(lineWidth: 1.0)
            .fill(axisInfo.color)
            // grid vertical to axis
            ForEach(axisInfo.gridValues, id: \.self) { gridValue in
                let gridPoint = canvas.locOnCanvas(CGPoint(x: gridValue, y: 0))
                Path { context in
                    context.move(to: CGPoint(x: gridPoint.x, y: 0))
                    context.addLine(to: CGPoint(x: gridPoint.x, y: canvas.canvasHeight))
                }
                .stroke(lineWidth: 0.5)
                .fill(axisInfo.gridColor)
            }
            // label along axis
            ForEach(axisInfo.labelValues, id: \.self) { labelValue in
                let labelPoint = canvas.locOnCanvas(CGPoint(x: labelValue, y: 0))
                labelContent(labelValue)
                    .position(x: labelPoint.x, y: axisPoint.y)
            }

        }
    }
}
public struct YAxisView: View {
    public typealias LabelGen = ((CGFloat) -> AnyView)
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
            let axisPoint = canvas.locOnCanvas(CGPoint(x: axisInfo.axisValue, y: 0))
            Path { context in
                context.move(to: CGPoint(x: axisPoint.x, y: 0))
                context.addLine(to: CGPoint(x: axisPoint.x, y: canvas.canvasHeight))
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
            ForEach(axisInfo.labelValues, id: \.self) { labelValue in
                let labelPoint = canvas.locOnCanvas(CGPoint(x: 0, y:labelValue))
                labelContent(labelValue)
                    .position(x: axisPoint.x, y: labelPoint.y)
                let _ = { print("pos \(axisPoint.x), \(labelPoint.y)")}()
            }

        }
            
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
                .stroke(style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                .fill(datum.lineColor)
                .clipped()

                ForEach(datum.dataPoints) { data in
                    datum.vertexSymbol(data)
                        .position(canvas.locOnCanvas(data.loc))
                        .foregroundColor(datum.lineColor)
                    //                        Text(datum.valueLabelFormatter(data.loc))
                    //                            .help(datum.tooltipFormatter(data.loc))
                    //                            .position(canvas.locOnCanvas(data.loc).move(datum.labelOffset))
                    //                            .foregroundColor(datum.lineColor)
                    //                            .font(.footnote)
                }
            } else {
                Text("No data for graph")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            if let info = datum.yAxisInfo {
                YAxisView(canvas: canvas , axisInfo: info,
                          labelContent: info.labelContent)
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


