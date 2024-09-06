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
            EditableDateExample()
                .tabItem({ Text("EditableDate")})
            EditablePickerExample()
                .tabItem({ Text("EditablePickerExample")})
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

            Text("text1 value: \(text1)").focusable()
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

struct EditableDateExample: View {
    @State private var date = Date()
    var body: some View {
        VStack {
            EditableDate(date: $date, displayComponents: [.date])
            EditableDate(date: $date, displayComponents: [.date])
                .indirectEdit()
            EditableDate(date: $date, displayComponents: [.hourAndMinute])
            EditableDate(date: $date, displayComponents: [.hourAndMinute])
                .indirectEdit()
            Text("value: \(date.formatted())")
                .focusable()
        }
        .onChange(of: date, perform: { _ in
            print("date is changed")
        })

    }
}


struct EditablePickerExample: View {
    @State private var selection = "Hello"
    var body: some View {
        VStack {
            EditablePicker(value: $selection, pickerContent: {
                Text("Hello").tag("Hello")
                Text("World").tag("World")
                Text("Konnichiwa").tag("Konnichiwa")
                Text("Sekai").tag("Sekai")
            }, formatter: { $0 })
            EditablePicker(value: $selection, pickerContent: {
                Text("Hello").tag("Hello")
                Text("World").tag("World")
                Text("Konnichiwa").tag("Konnichiwa")
                Text("Sekai").tag("Sekai")
            }, formatter: { $0 })
                .indirectEdit()
            Text("value: \(selection)")
                .focusable()
        }
        .onChange(of: selection, perform: { _ in
            print("selection is changed")
        })

    }
}
