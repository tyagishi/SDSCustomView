//
//  GraphData.swift
//
//  Created by : Tomoaki Yagishita on 2021/10/07
//  © 2021  SmallDeskSoftware
//

import Foundation
import SwiftUI
import SDSCGExtension

public class GraphData: ObservableObject {
    @Published var graphDatum: [PolylineGraphDatum]
    @Published var xRange: ClosedRange<Double>
    
    public init(_ datum: PolylineGraphDatum, xRange: ClosedRange<Double>? = nil) {
        self.graphDatum = [datum]
        self.xRange = xRange ?? datum.xValueRange
    }
    
    public init(_ data: [PolylineGraphDatum], xRange: ClosedRange<Double>) {
        self.graphDatum = data
        self.xRange = xRange
    }
}

public class PolylineGraphDatum: ObservableObject, Identifiable {
    public let id = UUID()
    @Published var dataPoints:[DataPoint]
    @Published var xValueRange: ClosedRange<Double>
    @Published var yValueRange: ClosedRange<Double>
    let vertexSymbol: AnyView
    @Published var lineColor: Color
    @Published public var canvas: SDSCanvas
    let labelOffset: CGVector
    let labelXValus: [CGFloat]
    let labelXFormatter: ((CGFloat)->String)

    public init(_ dataSet: [DataPoint],
         color: Color = Color.red, vertexSymbol: () -> AnyView,
         xValueRange: ClosedRange<Double>? = nil, yValueRange: ClosedRange<Double>? = nil,
         size: CGSize = CGSize.zero, canvas: SDSCanvas? = nil,
         labelOffset: CGVector = .zero,
         labelXValues: [CGFloat] = [],
         labelXFormatter: @escaping ((CGFloat)->String) = {_ in ""} ) {
        self.dataPoints = dataSet
        self.lineColor = color
        self.vertexSymbol = vertexSymbol()
        let calcedXValueRange = xValueRange ?? ClosedRange(uncheckedBounds: (dataSet.map({$0.loc.x}).min() ?? 0.0, dataSet.map({$0.loc.x}).max() ?? 100.0))
        let calcedYValueRange = yValueRange ?? ClosedRange(uncheckedBounds: (dataSet.map({$0.loc.y}).min() ?? 0.0, dataSet.map({$0.loc.y}).max() ?? 100.0))
        self.xValueRange = calcedXValueRange
        self.yValueRange = calcedYValueRange
        self.labelOffset = labelOffset
        self.labelXValus = labelXValues
        self.labelXFormatter = labelXFormatter
        if let canvas = canvas {
            self.canvas = canvas
        } else {
            let adjustedXRange = calcedXValueRange.expand(toLower: calcedXValueRange.width * 0.1 , toUpper: calcedXValueRange.width * 0.1)
            let adjustedYRange = calcedYValueRange.expand(toLower: calcedYValueRange.height * 0.1, toUpper: calcedYValueRange.height * 0.1)
            let xyScale = CGVector(dx: size.width / adjustedXRange.width,
                                   dy: size.height / adjustedYRange.height)
            let llPoint = CGPoint(x: adjustedXRange.lowerBound,
                                  y: adjustedYRange.lowerBound)
            self.canvas = SDSCanvas(llValue: llPoint, xyScale: xyScale, canvasSize: size)
        }
    }
    
    var dataSetForGraph: [DataPoint] {
        get {
            dataPoints
        }
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
