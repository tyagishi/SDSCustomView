//
//  DataPoint.swift
//
//  Created by : Tomoaki Yagishita on 2021/09/16
//  © 2021  SmallDeskSoftware
//

import Foundation
import CoreGraphics

typealias DataPoints = [DataPoint]

public struct DataPoint: Identifiable {
    public let id: UUID
    public var loc: CGPoint

    public init(_ loc: CGPoint) {
        self.id = UUID()
        self.loc = loc
    }

    static public func randomSample(_ num: Int, yRange: ClosedRange<Double>, xScale: Double = 1, yScale: Double = 1) -> [DataPoint] {
        var dPoints:[DataPoint] = []
        for index in 0..<num {
            let newLoc = DataPoint(CGPoint(x: Double(index) * xScale, y: Double.random(in: yRange) * yScale))
            dPoints.append(newLoc)
        }
        return dPoints
    }
}
