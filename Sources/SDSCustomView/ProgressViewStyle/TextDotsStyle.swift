//
//  TextDotsStyle.swift
//  SDSCustomView
//
//  Created by Tomoaki Yagishita on 2025/03/14.
//

import Foundation
import SwiftUI

public struct TextDotsStyle: ProgressViewStyle {
    let unitText: String
    let completeNum: Int
    let updateFrequency: CGFloat
    @State private var showNum: Int = 0

    public init(unitText: String,completeNum: Int, updateFrequency: CGFloat) {
        self.unitText = unitText
        self.completeNum = completeNum
        self.updateFrequency = updateFrequency
    }

    public func makeBody(configuration: Configuration) -> some View {
        Text(Array(repeating: unitText, count: completeNum).joined())
            .hidden()
            .overlay(alignment: .leading, content: {
                let showNum = localCompNum(configuration: configuration)
                Text(Array(repeating: unitText, count: showNum).joined())
            })
            .onReceive(Timer.TimerPublisher(interval: updateFrequency, runLoop: .main, mode: .default).autoconnect(), perform: { _ in
                guard configuration.fractionCompleted == nil else { return }
                showNum += 1
                showNum %= (completeNum+1)
            })
    }
    
    func localCompNum(configuration: Configuration) -> Int {
        if let ratio = configuration.fractionCompleted {
            return Int(Double(completeNum) * ratio)
        }
        return showNum
    }
}

extension ProgressViewStyle where Self == TextDotsStyle {
    public static func textDots(unitText: String = ".", completeNum: Int = 5, updateFrequency: CGFloat = 0.5) -> Self {
        return .init(unitText: unitText, completeNum: completeNum, updateFrequency: updateFrequency)
    }
}
