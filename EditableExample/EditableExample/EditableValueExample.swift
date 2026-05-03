//
//  EditableValueExample.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/05/03.
//

import SwiftUI
import SDSCustomView

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
