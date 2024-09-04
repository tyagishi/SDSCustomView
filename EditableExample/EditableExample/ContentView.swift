//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2024/08/20
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import SDSCustomView

struct ContentView: View {
    var body: some View {
        TabView {
            EditableTextExample()
                .tabItem({ Text("EditableText")})
            EditableValueExample()
                .tabItem({ Text("EditableValue")})
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct EditableTextExample: View {
    @State private var text1 = "Text1"
    var body: some View {
        VStack {
            EditableText(value: $text1, placeholder: "placeholder", editClick: 1, alignment: .leading)
            EditableText(value: $text1, placeholder: "placeholder", editClick: 1, alignment: .leading)
                .indirectEdit()

            Text("text1 value: \(text1)")
        }

    }
}

struct EditableValueExample: View {
    @State private var value = 123
    var body: some View {
        VStack {
            EditableValue(value: $value, format: IntegerFormatStyle.number)
            EditableValue(value: $value, format: IntegerFormatStyle.number, initMode: .edit)
//                .indirectEdit()
            EditableValue(value: $value, format: IntegerFormatStyle.number)
                .indirectEdit()

            Button(action: { value += 1}, label: { Text("+1") })
            Text("value: \(value)")
        }
        .onChange(of: value, perform: { _ in
            print("value is changed")
        })

    }
}
