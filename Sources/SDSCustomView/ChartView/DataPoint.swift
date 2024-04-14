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

    public static func randomSample(_ num: Int, yRange: ClosedRange<Double>, xScale: Double = 1, yScale: Double = 1) -> [DataPoint] {
        var dPoints: [DataPoint] = []
        _ = (0..<num).map({ DataPoint(CGPoint(x: Double($0) * xScale, y: Double.random(in: yRange) * yScale)) }).map({ dPoints.append($0) })
        return dPoints
    }
}
