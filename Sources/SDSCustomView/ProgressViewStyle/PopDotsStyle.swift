//
//  PopDotsStyle.swift
//  SDSCustomView
//
//  Created by Tomoaki Yagishita on 2025/03/17.
//

import Foundation
import SwiftUI
import SDSMacros

@available(iOS 17.0, macOS 14.0, *)
public struct PopDotsStyle: ProgressViewStyle {
    let unitText: String
    let dotNum: Int
    @State private var showNum: Int = 0

    public init(unitText: String, dotNum: Int) {
        self.unitText = unitText
        self.dotNum = dotNum
    }

    public func makeBody(configuration: Configuration) -> some View {
        Text(Array(repeating: unitText, count: dotNum).joined())
            .hidden()
            .phaseAnimator(SerialPopPhase.cases(for: dotNum), content: { view, phase in
                view.hidden()
                    .overlay {
                        HStack(spacing: 0) {
                            ForEach(0..<dotNum, id: \.self, content: { index in
                                Text(".").offset(y: phase.offset(for: index) )
                            })
                        }
                    }
            }, animation: { phase in
                if phase.isTop { return .easeIn }
                return .easeOut
            })
    }
}

@IsCheckEnum
public enum SerialPopPhase: Equatable {
    case top(Int)
    case bottom(Int)
    
    public func offset(for index: Int) -> CGFloat {
        switch self {
        case .top(let value):
            if index == value { return -10 }
            return 0
        case .bottom:
            return   0
        }
    }
}

extension SerialPopPhase {
    static func cases(for num: Int) -> [SerialPopPhase] {
        return Array(0..<num).map({ [SerialPopPhase.top($0), .bottom($0)]}).flatMap({ $0 })
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension ProgressViewStyle where Self == PopDotsStyle {
    public static func popDots(unitText: String = ".", dotNum: Int = 5) -> Self {
        return .init(unitText: unitText, dotNum: dotNum)
    }
}
