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
            EditableTokenExample()
                .tabItem({ Text("EditableToken")})
            EditableTextExample()
                .tabItem({ Text("EditableText")})
            EditableValueExample()
                .tabItem({ Text("EditableValue")})
            EditableDateExample()
                .tabItem({ Text("EditableDate")})
            EditablePickerExample()
                .tabItem({ Text("EditablePickerExample")})
            EditablePicker2Example()
                .tabItem({ Text("EditablePicker2Example")})
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

class TestElement: ObservableObject {
    var tags: [String] = []
    
    init(tags: [String]) {
        self.tags = tags
    }
}

struct EditableTokenExample: View {
    let allTokens = ["Hello", "World", "Hallo", "Konnichiwa"]
    @State private var tokens: [String] = ["Hello"]
    @StateObject private var element = TestElement(tags: ["Hello"])
    @State private var text1 = "Text1"
    var body: some View {
        VStack {
            Group {
                let getSet = (getter: {
                    tokens
                }, setter: { strings in
                    tokens = strings
                })
                EditableToken(getSet: getSet, selectableTokens: allTokens)
                Text("tokens value: \(tokens)").focusable()
                Button(action: {
                    if !tokens.contains("Konnichiwa") {
                        tokens.append("Konnichiwa")
                    }
                }, label: { Text("Add Konnichiwa") })
            }
            Group {
                let getSet = (getter: {
                    element.tags
                }, setter: { strings in
                    element.tags = strings
                })
                EditableToken(getSet: getSet, selectableTokens: allTokens)
                Text("tokens value: \(element.tags)").focusable()

                Button(action: {
                    if !element.tags.contains("Konnichiwa") {
                        element.objectWillChange.send()
                        element.tags.append("Konnichiwa")
                    }
                }, label: { Text("Add Konnichiwa") })
            }
            //.indirectEdit()
        }

    }
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
            EditableValue(value: $value, format: IntegerFormatStyle.number)
//                .indirectEdit()
            EditableValue(value: $value, format: IntegerFormatStyle.number)
                .indirectEdit()
            EditableValue(value: $value, format: IntegerFormatStyle.number, initMode: .edit)
                .indirectEdit()

            Button(action: { value += 1}, label: { Text("+1") })
            Text("value: \(value)")
        }
        .onChange(of: value, {
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
        .onChange(of: date, {
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
        .onChange(of: selection, {
            print("selection is changed")
        })

    }
}

extension String: Identifiable {
    public var id: Self { return self }
}

struct EditablePicker2Example: View {
    @State private var selection = "Hello"
    @State private var dummy = "Hello world"
    
    @FocusState var focus: String?
    
    var body: some View {
        VStack {
            EditablePicker2(value: $selection, contentValues: ["Hello", "World", "Konnichiwa", "Sekai"], formatter: { $0 })
            EditablePicker2(value: $selection, contentValues: ["Hello", "World", "Konnichiwa", "Sekai"], formatter: { $0 })
                .indirectEdit()
            Text("value: \(selection)")
                .focusable()
            TextField("DummyField", text: $dummy)
        }
        .onChange(of: selection, {
            print("selection is changed")
        })
        .onChange(of: focus) { oldValue, newValue in
            print("focus changed \(focus)")
        }

    }
}
