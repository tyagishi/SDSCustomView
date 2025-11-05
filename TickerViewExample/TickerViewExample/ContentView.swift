//
//  ContentView.swift
//  TickerViewExample
//
//  Created by Tomoaki Yagishita on 2025/11/02.
//

import SwiftUI
import SDSCustomView
import SDSViewExtension
import SDSStringExtension

struct ContentView: View {
    @State private var text = "Hello, world!"
    @State private var width: Double = 100
    @State private var firstViewSelection = true

    var body: some View {
        VStack {
            TextField("Width", value: $width, format: FloatingPointFormatStyle.number)
            TextField(text: $text, label: { Text("Text:") })
            
            TickerText(text: text, slideFrequency: 0.5, slideSize: -3)
                .frame(width: width).border(.red)
                .clipped()
            
            Text("Change width/text, TickerText will be used iff width is not enough for text")
            FlexibleTickerText(text: text)
                .frame(width: width)
                .clipped()
                .border(.blue)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct FlexibleTickerText: View {
    let text: String
    @State private var viewSize: CGSize = .zero
    @State private var textSize: CGSize = .zero
    var body: some View {
        let stringSize = text.size(.body)
        GeometryReader { proxy in
            let viewSize = proxy.size
            if stringSize.width < viewSize.width {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                TickerText(text: text, slideFrequency: 0.2, slideSize: -4)
            }
        }
        .frame(height: text.size().height.rounded(.awayFromZero))
    }
}
