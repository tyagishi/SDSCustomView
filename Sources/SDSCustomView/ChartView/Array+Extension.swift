//
//  Array+Extension.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/29
//  © 2022  SmallDeskSoftware
//

import Foundation

extension Array where Element == DataPoint {
    public var xValueRange: ClosedRange<Double>? {
        if let xMin = self.map({$0.loc.x}).min(),
           let xMax = self.map({$0.loc.x}).max() {
            return ClosedRange<Double>(uncheckedBounds: (xMin, xMax))
        }
        return nil
    }
    public var yValueRange: ClosedRange<Double>? {
        if let yMin = self.map({$0.loc.y}).min(),
           let yMax = self.map({$0.loc.y}).max() {
            return ClosedRange<Double>(uncheckedBounds: (yMin, yMax))
        }
        return nil
    }
}
