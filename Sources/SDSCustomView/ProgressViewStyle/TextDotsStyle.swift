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
    @State private var showNum: Int = 1

    public init(unitText: String = ".",completeNum: Int = 5) {
        self.unitText = unitText
        self.completeNum = completeNum
    }

    public func makeBody(configuration: Configuration) -> some View {
        Text(Array(repeating: unitText, count: completeNum).joined())
            .hidden()
            .overlay(content: {
                let showNum = localCompNum(configuration: configuration)
                Text(Array(repeating: unitText, count: showNum).joined())
                .frame(maxWidth: .infinity, alignment: .leading)
            })
            .onReceive(Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default).autoconnect(), perform: { _ in
                guard configuration.fractionCompleted == nil else { return }
                self.showNum = (showNum + 1) % (completeNum+1)
            })
    }
    
    func localCompNum(configuration: Configuration) -> Int {
        if let ratio = configuration.fractionCompleted {
            return max(Int(Double(completeNum) * ratio), 0)
        }
        return showNum
    }
}
