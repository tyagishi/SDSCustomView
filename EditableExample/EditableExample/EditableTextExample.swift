//
//  EditableTextExample.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/04/02.
//


import SwiftUI
import SDSCustomView

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