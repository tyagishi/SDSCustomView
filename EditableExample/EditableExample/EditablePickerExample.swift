//
//  EditablePickerExample.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/05/03.
//

import SwiftUI
import SDSCustomView

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
