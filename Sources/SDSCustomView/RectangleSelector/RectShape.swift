//
//  RectShape.swift
//  SDSCustomView
//
//  Created by Tomoaki Yagishita on 2025/02/04.
//

import Foundation
import SwiftUI

public struct RectShape: Shape {
    let rect: CGRect

    public init(rect: CGRect) {
        self.rect = rect
    }

    public func path(in rect: CGRect) -> Path {
        return self.rect.rectPath
    }
}

extension CGRect {
    var rectPath: Path {
        var path = Path()
        path.move(to: CGPoint(x: minX, y: minY))
        path.addLine(to: CGPoint(x: minX, y: maxY))
        path.addLine(to: CGPoint(x: maxX, y: maxY))
        path.addLine(to: CGPoint(x: maxX, y: minY))
        path.closeSubpath()
        return path
    }
}
