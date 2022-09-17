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
    @Published public var xValueRange: ClosedRange<Double>
    @Published public var yValueRange: ClosedRange<Double>
    let vertexSymbol: AnyView
    @Published var lineColor: Color
    @Published public var canvas: SDSCanvas
    let labelOffset: CGVector
    
    let valueLabelFormatter: ((CGPoint)->String)
    
    let tooltipFormatter: (CGPoint) -> String
    
    // yAxis
    public var yAxisInfo: AxisInfo?
    
    

    public init(_ dataSet: [DataPoint],
                linecolor: Color = Color.red, vertexSymbol: (() -> AnyView)? = nil,
                xValueRange: ClosedRange<Double>? = nil, yValueRange: ClosedRange<Double>? = nil,
                size: CGSize, canvas: SDSCanvas? = nil,
                labelOffset: CGVector = .zero,
                valueLabelFormatter: @escaping ((CGPoint) -> String) = {_ in ""},
                tooltipFormatter: @escaping((CGPoint)->String) = {_ in ""} ) {
        precondition(size != .zero || canvas != nil)
        self.dataPoints = dataSet
        self.lineColor = linecolor
        self.vertexSymbol = vertexSymbol?() ?? EmptyView().anyView()
        let calcedXValueRange = xValueRange ?? ClosedRange(uncheckedBounds: (dataSet.map({$0.loc.x}).min() ?? 0.0, dataSet.map({$0.loc.x}).max() ?? 100.0))
        let calcedYValueRange = yValueRange ?? ClosedRange(uncheckedBounds: (dataSet.map({$0.loc.y}).min() ?? 0.0, dataSet.map({$0.loc.y}).max() ?? 100.0))
        self.xValueRange = calcedXValueRange
        self.yValueRange = calcedYValueRange
        self.labelOffset = labelOffset
        
        self.valueLabelFormatter = valueLabelFormatter
        
        self.tooltipFormatter = tooltipFormatter
        
        if let canvas = canvas {
            self.canvas = canvas
        } else {
            var adjustedXRange = calcedXValueRange.expand(toLower: calcedXValueRange.width * 0.1 , toUpper: calcedXValueRange.width * 0.1)
//            if adjustedXRange.width <= 10 {
//                adjustedXRange = adjustedXRange.expand(toLower: 10, toUpper: 10)
//            }
            var adjustedYRange = calcedYValueRange.expand(toLower: calcedYValueRange.height * 0.1, toUpper: calcedYValueRange.height * 0.1)
            if adjustedYRange.height <= 10 {
                adjustedYRange = adjustedYRange.expand(toLower: 10, toUpper: 10)
            }
            let xyScale = CGVector(dx: size.width / adjustedXRange.width,
                                   dy: size.height / adjustedYRange.height)
            let llPoint = CGPoint(x: adjustedXRange.lowerBound,
                                  y: adjustedYRange.lowerBound)
            self.canvas = SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
        }
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
    
    public func suitableCanvas(for size: CGSize,
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
//        print("llPoint \(llPoint)")
//        print("xyScale \(xyScale)")
        return SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
    }
    
}
