//
//  ContentView.swift
//  TextFieldWithSuggestionsExample
//
//  Created by Tomoaki Yagishita on 2025/07/29.
//

import SwiftUI
import SDSCustomView

struct ContentView: View {
    @State private var displayText = "Hello"

    var body: some View {
        VStack {
            TextFieldWithSuggestions($displayText, suggestions: { _ in
                return (1...50).map({ String($0) })
//                return ["abc", "def", "ghi"]
            }, trigger: { text in
                print("trigger: \(text)")
                return text.hasSuffix("a")
            }, handler: { (current, selected) in
                print("current: \(current) selected: \(selected)")
                return current.dropLast() + selected + ", "
            }).zIndex(1)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
