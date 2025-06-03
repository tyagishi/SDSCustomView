//
//  TickerText.swift
//  SDSCustomView
//
//  Created by Tomoaki Yagishita on 2025/05/04.
//

import SwiftUI

struct ViewSizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

@available(iOS 15, macOS 12, *)
public struct TickerText: View {
    @State private var offsetValue: CGFloat = 0
    @State private var textWidth: CGFloat = 10

    let text: String
    let slideFrequency: CGFloat
    let slideSize: CGFloat
    
    public init(text: String, slideFrequency: CGFloat, slideSize: CGFloat) {
        self.text = text
        self.slideFrequency = slideFrequency
        self.slideSize = slideSize
    }
    
    public var body: some View {
        Text(text)
            .lineLimit(1).fixedSize()
            .background {
                GeometryReader { geomProxy in
                    Color.clear
                        .preference(key: ViewSizePreferenceKey.self, value: geomProxy.size)
                }
            }
            .hidden()
            .onPreferenceChange(ViewSizePreferenceKey.self, perform: { newSize in
                textWidth = newSize.width
            })
            .overlay(alignment: .leading) {
                Text(text+text)
                    .lineLimit(1).fixedSize()
                    .offset(x: offsetValue)
                    .onReceive(Timer.publish(every: slideFrequency, on: .main, in: .default).autoconnect()) { _ in
                        self.offsetValue = CGFloat(Int(self.offsetValue + slideSize) % Int(textWidth))
                    }
            }
            .clipped()
    }
}
