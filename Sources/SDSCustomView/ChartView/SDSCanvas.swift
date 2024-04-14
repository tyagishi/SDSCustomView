//
//  SDSCanvas.swift
//
//  Created by : Tomoaki Yagishita on 2022/02/18
//  © 2022  SmallDeskSoftware
//

import Foundation
import CoreGraphics
//
//
//
//  ^    ^
//  |    |
//  |    |
//       |
//  h    |
//  e    |
//  i    |
//  g    |
//  h    |
//  t    |
//       |
//  |    |
//  | ---+-------------------->
//  |    |
//  vLL  |
//   <---- canvasSize.width ->
//
// llValue shows data (x,y) which will be mapped to l(ower) l(eft) corner
// xyScale should have scaling factor along X/Y-axis
// canvasSize has size of canvas (without any scaling)
//
// note: always coordinate system start from lowerleft
//

/// struct for holding drawing canvas info for plotting
/// plotting data should be drawable with this struct i.e. (x,y) can be mapped to (x,y) on canvas
///
public struct SDSCanvas {
    /// (x,y) value for point which will be appeared at lower-left corner
    public var llValue: CGPoint
    /// scaling factor along x/y axis
    public var xyScale: CGVector
    /// canvas size
    public var canvasSize: CGSize
    
    public init(llValue: CGPoint, xyScale: CGVector, canvasSize: CGSize) {
        self.llValue = llValue
        self.xyScale = xyScale
        self.canvasSize = canvasSize
    }

    public var llValueX: CGFloat {
        llValue.x
    }
    public var llValueY: CGFloat {
        llValue.y
    }
    public var xScale: CGFloat {
        xyScale.dx
    }
    public var yScale: CGFloat {
        xyScale.dy
    }

    public var canvasWidth: CGFloat {
        canvasSize.width
    }
    public var canvasHeight: CGFloat {
        canvasSize.height
    }
    
    // swiftlint:disable identifier_name
    func locOnCanvas(_ pos: CGPoint) -> CGPoint {
        let x = (pos.x - self.llValueX) * self.xScale
        let y = (pos.y - self.llValueY) * self.yScale
        return invertedY(point: CGPoint(x: x, y: y))
    }
    // calc reveresed/scaled point on canvas
    func invertedY(point: CGPoint) -> CGPoint {
        let newY = self.canvasHeight - point.y
        return CGPoint(x: point.x, y: newY)
    }
    // swiftlint:enable identifier_name
}
