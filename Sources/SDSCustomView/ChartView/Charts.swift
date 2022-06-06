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

public struct AxisInfo {
    let axisValue: CGFloat // for X-Axis, this is Y-Value,for Y-Axis other way around
    let axisEnds: (from: CGFloat, to: CGFloat)
    let color: Color
    let labelValues: [CGFloat] // value in data coordinate
    let formatter: ((CGFloat) -> String)?
    public init(axisValue: CGFloat, axisEnds: (from: CGFloat, to: CGFloat),
                color: Color, labelValues: [CGFloat], formatter: ((CGFloat) -> String)? = nil) {
        self.axisValue = axisValue
        self.axisEnds = axisEnds
        self.color = color
        self.labelValues = labelValues
        self.formatter = formatter
    }
}

public struct GridInfo {
    let axisValues: [CGFloat] // for grid along X-Axis, these are Y-Values,for Y-Axis other way around
    let axisEnds: (from: CGFloat, to: CGFloat)
    let color: Color
    public init(axisValues: [CGFloat], axisEnds: (from: CGFloat, to: CGFloat),
                color: Color) {
        self.axisValues = axisValues
        self.axisEnds = axisEnds
        self.color = color
    }
}


public enum AxisConfig {
    case none
    //case coordinateValue(AxisInfo) // in draw coordinate // will be implemented in future version
    case plotValue(AxisInfo) // value in data coordinate
}

public enum GridConfig {
    case none
    case plotValues(GridInfo) // value in data coordinate
}

public struct Charts<tContent: View, legendView: View>: View {
    @ObservedObject var graphData: GraphData
    var title: tContent
    let legend: legendView
    let xAxis: AxisConfig
    let yAxis: AxisConfig
    let xGrid: GridConfig
    let yGrid: GridConfig

    public init(_ graphData: GraphData,
                @ViewBuilder title: () -> tContent,
                @ViewBuilder legend: () -> legendView,
                xAxis: AxisConfig, yAxis: AxisConfig,
                xGrid: GridConfig, yGrid: GridConfig) {
        self.graphData = graphData
        self.title = title()
        self.legend = legend()
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.xGrid = xGrid
        self.yGrid = yGrid
    }
    
    public var body: some View {
        ZStack {
            title
            legend
            ForEach(graphData.graphDatum) { datum in
                PolylineView(datum, canvas: datum.canvas, xAxis: xAxis, yAxis: yAxis,
                             xGrid: xGrid, yGrid: yGrid)
            }
        }
    }
}


public struct XAxisView: View {
    let canvas: SDSCanvas
    let axisValue: CGFloat
    let axisEnds: (from: CGFloat, to: CGFloat)
    let color: Color
    let labelValues: [CGFloat]
    let formatter: ((CGFloat)->String)?

    @State private var offset = CGSize.zero

    public init(canvas: SDSCanvas, axisValue: CGFloat, axisEnds: (from: CGFloat, to: CGFloat), color: Color,
                labelValues: [CGFloat], formatter: ((CGFloat)->String)? = nil) {
        self.canvas = canvas
        self.axisValue = axisValue
        self.axisEnds = axisEnds
        self.color = color
        self.labelValues = labelValues
        self.formatter = formatter
    }

    public var body: some View {
        ZStack {
            Path { context in
                context.move(to: canvas.locOnCanvas(.init(x: axisEnds.from, y: axisValue)))
                context.addLine(to: canvas.locOnCanvas(.init(x: axisEnds.to, y: axisValue)))
            }
            .stroke(lineWidth: 1.0)
            .fill(color)
            if let formatter = formatter {
                ForEach(labelValues, id: \.self) { value in
                    Text(formatter(value))
                        .readGeom(onChange: { geomProxy in
                            offset = geomProxy.size
                        })
                        .position(canvas.locOnCanvas(.init(x: value, y: axisValue)).move(offset.width * 0, offset.height * 1))
                        .font(.footnote)
                }
            }
        }
    }
}
public struct YAxisView: View {
    let canvas: SDSCanvas
    let axisValue: CGFloat
    let axisEnds: (from: CGFloat, to: CGFloat)
    let color: Color
    let labelValues: [CGFloat]
    let formatter: ((CGFloat)->String)?

    @State private var offset = CGSize.zero

    public init(canvas: SDSCanvas, axisValue: CGFloat, axisEnds: (from: CGFloat, to: CGFloat), color: Color,
                labelValues: [CGFloat], formatter: ((CGFloat)->String)? = nil) {
        self.canvas = canvas
        self.axisValue = axisValue
        self.axisEnds = axisEnds
        self.color = color
        self.labelValues = labelValues
        self.formatter = formatter
    }

    public var body: some View {
        ZStack {
            Path { context in
                context.move(to: canvas.locOnCanvas(.init(x: axisValue, y: axisEnds.from)))
                context.addLine(to: canvas.locOnCanvas(.init(x: axisValue, y: axisEnds.to)))
            }
            .stroke(lineWidth: 1.0)
            .fill(color)
            if let formatter = formatter {
                ForEach(labelValues, id: \.self) { value in
                    Text(formatter(value))
                        .readGeom(onChange: { geomProxy in
                            offset = geomProxy.size
                        })
                        .position(canvas.locOnCanvas(.init(x: axisValue, y: value)).move(offset.width * -1, offset.height * 0))
                        .font(.footnote)
                }
            }
        }
            
    }
}

struct PolylineView: View {
    @ObservedObject var datum:PolylineGraphDatum
    let canvas: SDSCanvas
    let xAxis: AxisConfig
    let yAxis: AxisConfig
    let xGrid: GridConfig
    let yGrid: GridConfig

    init(_ datum: PolylineGraphDatum, canvas: SDSCanvas,
         xAxis: AxisConfig, yAxis: AxisConfig,
         xGrid: GridConfig, yGrid: GridConfig) {
        self.datum = datum
        self.canvas = canvas
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.xGrid = xGrid
        self.yGrid = yGrid
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
                        Text(datum.valueYLabelFormatter(data.loc.y))
                            .help(datum.tooltipFormatter(data.loc))
                            .position(canvas.locOnCanvas(data.loc).move(datum.labelOffset))
                            .foregroundColor(datum.lineColor)
                            .font(.footnote)
                    }
                } else {
                    Text("No data for graph")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                if case .plotValue(let info) = xAxis {
                    XAxisView(canvas: canvas , axisValue: info.axisValue, axisEnds: (info.axisEnds.from, info.axisEnds.to), color: .black,
                              labelValues: info.labelValues, formatter: info.formatter)
                }
                if case .plotValues(let gridInfo) = xGrid {
                    ForEach(gridInfo.axisValues, id: \.self) { gridValue in
                        XAxisView(canvas: canvas, axisValue: gridValue, axisEnds: gridInfo.axisEnds,
                                  color: gridInfo.color, labelValues: [], formatter: { _ in ""})
                    }
                }

                if case .plotValue(let info) = yAxis {
                    YAxisView(canvas: canvas , axisValue: info.axisValue, axisEnds: (info.axisEnds.from, info.axisEnds.to), color: .black,
                              labelValues: info.labelValues, formatter: info.formatter)
                }
                if case .plotValues(let gridInfo) = yGrid {
                    ForEach(gridInfo.axisValues, id: \.self) { gridValue in
                        YAxisView(canvas: canvas, axisValue: gridValue, axisEnds: gridInfo.axisEnds,
                                  color: gridInfo.color, labelValues: [], formatter: { _ in ""})
                    }
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


