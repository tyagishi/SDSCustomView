//
//  PolylineGraphDatum.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/29
//  © 2022  SmallDeskSoftware
//

import Foundation
import SwiftUI
import SDSCGExtension

public class PolylineGraphDatum: ObservableObject, Identifiable {
    public let id = UUID()

    @Published var dataPoints:[DataPoint]
    @Published public var canvas: SDSCanvas

    //    @Published public var xValueRange: ClosedRange<Double>
//    @Published public var yValueRange: ClosedRange<Double>

    @Published var lineColor: Color

    let vertexSymbol: ((DataPoint) -> AnyView)
//    let labelOffset: CGVector
//    let valueLabelFormatter: ((CGPoint)->String)
//    let tooltipFormatter: (CGPoint) -> String
    
    // yAxis
    public var yAxisInfo: AxisInfo?

    public init(_ dataSet: [DataPoint],
                linecolor: Color = Color.red, vertexSymbol: @escaping ((DataPoint) -> AnyView) = { _ in EmptyView().anyView()},
//                xValueRange: ClosedRange<Double>? = nil, yValueRange: ClosedRange<Double>? = nil,
//                size: CGSize,
                canvas: SDSCanvas) {
//                labelOffset: CGVector = .zero,
//                valueLabelFormatter: @escaping ((CGPoint) -> String) = {_ in ""},
//                tooltipFormatter: @escaping((CGPoint)->String) = {_ in ""} ) {
        self.dataPoints = dataSet
        self.canvas = canvas
        self.lineColor = linecolor
        self.vertexSymbol = vertexSymbol
//        let calcedXValueRange = xValueRange ?? ClosedRange(uncheckedBounds: (dataSet.map({$0.loc.x}).min() ?? 0.0, dataSet.map({$0.loc.x}).max() ?? 100.0))
//        let calcedYValueRange = yValueRange ?? ClosedRange(uncheckedBounds: (dataSet.map({$0.loc.y}).min() ?? 0.0, dataSet.map({$0.loc.y}).max() ?? 100.0))
//        self.xValueRange = calcedXValueRange
//        self.yValueRange = calcedYValueRange
//        self.labelOffset = labelOffset
//
//        self.valueLabelFormatter = valueLabelFormatter
//
//        self.tooltipFormatter = tooltipFormatter
//
//        if let canvas = canvas {
//        } else {
//            var adjustedXRange = calcedXValueRange.expand(toLower: calcedXValueRange.width * 0.1 , toUpper: calcedXValueRange.width * 0.1)
////            if adjustedXRange.width <= 10 {
////                adjustedXRange = adjustedXRange.expand(toLower: 10, toUpper: 10)
////            }
//            var adjustedYRange = calcedYValueRange.expand(toLower: calcedYValueRange.height * 0.1, toUpper: calcedYValueRange.height * 0.1)
//            if adjustedYRange.height <= 10 {
//                adjustedYRange = adjustedYRange.expand(toLower: 10, toUpper: 10)
//            }
//            let xyScale = CGVector(dx: size.width / adjustedXRange.width,
//                                   dy: size.height / adjustedYRange.height)
//            let llPoint = CGPoint(x: adjustedXRange.lowerBound,
//                                  y: adjustedYRange.lowerBound)
//            self.canvas = SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
//        }
        self.yAxisInfo = nil
    }
    
    var dataSetForGraph: [DataPoint] {
        get {
            dataPoints
        }
    }
    
    public func hasEnoughData() -> Bool {
        return !dataPoints.isEmpty
    }
    
    func suitableTestCanvas(for size: CGSize) -> SDSCanvas {
        let llPoint = CGPoint(x: -1, y: -10)
        let xyScale = CGVector(dx: 20, dy: 2)
        
        return SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
    }
    
    static public func suitableCanvasFor(_ size: CGSize,
                                         xValueRange: ClosedRange<Double>,
                                         yValueRange: ClosedRange<Double>,
                                         xLowerPadding: CGFloat = 0.0,
                                         xUpperPadding: CGFloat = 0.0,
                                         yLowerPadding: CGFloat = 0.0,
                                         yUpperPadding: CGFloat = 0.0) -> SDSCanvas {
        let adjustedXRange = xValueRange.expand(toLower: xLowerPadding, toUpper: xUpperPadding)
        let adjustedYRange = yValueRange.expand(toLower: yLowerPadding, toUpper: yUpperPadding)

        let xyScale = CGVector(dx: size.width / adjustedXRange.width,
                               dy: size.height / adjustedYRange.height)
        let llPoint = CGPoint(x: adjustedXRange.lowerBound,
                              y: adjustedYRange.lowerBound)
        return SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
    }
    
//    public func suitableCanvas(for size: CGSize,
//                               xLowerPadding: CGFloat = 0.0,
//                               xUpperPadding: CGFloat = 0.0,
//                               yLowerPadding: CGFloat = 0.0,
//                               yUpperPadding: CGFloat = 0.0) -> SDSCanvas {
//        let adjustedXRange = xValueRange.expand(toLower: xLowerPadding, toUpper: xUpperPadding)
//        let adjustedYRange = yValueRange.expand(toLower: yLowerPadding, toUpper: yUpperPadding)
//        let xyScale = CGVector(dx: size.width / adjustedXRange.width,
//                               dy: size.height / adjustedYRange.height)
//        let llPoint = CGPoint(x: adjustedXRange.lowerBound,
//                              y: adjustedYRange.lowerBound)
////        print("llPoint \(llPoint)")
////        print("xyScale \(xyScale)")
//        return SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
//    }
    
//    static public func canvasFor(_ size: CGSize, dataPoints: [DataPoint]) -> SDSCanvas {
//        let xValueRange = dataPoints.xValueRange ?? 0...10
//        let yValueRange = dataPoints.yValueRange ?? 0...10
//        let llPoint = CGPoint(x: xValueRange.lowerBound, y: yValueRange.lowerBound)
//        let xyScale = CGVector(dx: size.width / xValueRange.width, dy: size.height / yValueRange.width)
//
//        return SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
//    }
    static public func canvasFor(_ size: CGSize, dataPoints: [DataPoint],
                                 xValueRange: ClosedRange<Double>? = nil,
                                 edgeInsetRatio: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) -> SDSCanvas {
        let xValueRange = xValueRange ?? (dataPoints.xValueRange ?? 0...10)
        let yValueRange = dataPoints.yValueRange ?? 0...10

        let leadingPadding = edgeInsetRatio.leading * xValueRange.width
        let trailingPadding = edgeInsetRatio.trailing * xValueRange.width
        let topPadding = edgeInsetRatio.top * yValueRange.width
        let bottomPadding = edgeInsetRatio.bottom * yValueRange.width

        let llPoint = CGPoint(x: xValueRange.lowerBound - leadingPadding, y: yValueRange.lowerBound - bottomPadding)

        let xyScale = CGVector(dx: size.width / (xValueRange.width + leadingPadding + trailingPadding),
                               dy: size.height / (yValueRange.width + topPadding + bottomPadding))

        return SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
    }

    /// generate canvas for Chart from given data ranges
    /// - Parameters:
    ///   - size: chart actual size (in dot)
    ///   - xValueRange: x value range
    ///   - yValueRange: y value range
    ///   - edgeInsetRatio: padding in dot
    /// - Returns: canvas for chart
    static public func canvasFor(_ size: CGSize, xValueRange: ClosedRange<Double>, yValueRange:ClosedRange<Double>,
                                 edgeInsetRatio: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) -> SDSCanvas {
        let chartSize = CGSize(width: size.width - edgeInsetRatio.leading - edgeInsetRatio.trailing,
                               height: size.height - edgeInsetRatio.top - edgeInsetRatio.bottom)

        let xScale = chartSize.width / xValueRange.width
        let yScale = chartSize.height / yValueRange.width

        let leadingInValue = edgeInsetRatio.leading / xScale
        //let trainingInValue = edgeInsetRatio.trailing / xScale

        //let topInValue = edgeInsetRatio.top / yScale
        let bottomInValue = edgeInsetRatio.bottom / yScale

        let llPoint = CGPoint(x: xValueRange.lowerBound - leadingInValue, y: yValueRange.lowerBound - bottomInValue)

        return SDSCanvas(llValue: llPoint, xyScale: CGVector(dx: xScale, dy: yScale), canvasSize: size)
    }

}
