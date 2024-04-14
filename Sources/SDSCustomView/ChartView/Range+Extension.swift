//
//  Range+Extension.swift
//
//  Created by : Tomoaki Yagishita on 2022/02/22
//  © 2022  SmallDeskSoftware
//

import Foundation

extension ClosedRange where Bound == Double {
    static var infRange: ClosedRange<Bound> {
        return ClosedRange(uncheckedBounds: (Double.infinity * -1, Double.infinity))
    }

    public var width: Double {
        self.upperBound - self.lowerBound
    }
    public var height: Double {
        self.upperBound - self.lowerBound
    }

    public var mid: Double {
        (self.upperBound + self.lowerBound) / 2.0
    }

    public func expand(lowerRatio: Double = 0.0, upperRatio: Double = 0.0) -> ClosedRange {
        let width = self.width
        let lower = self.lowerBound - width * lowerRatio
        let upper = self.upperBound + width * upperRatio
        return ClosedRange(uncheckedBounds: (lower, upper))
    }

    public func expand(toLower: Double, toUpper: Double) -> ClosedRange {
        return ClosedRange(uncheckedBounds: (self.lowerBound - toLower, self.upperBound + toUpper))
    }
}
