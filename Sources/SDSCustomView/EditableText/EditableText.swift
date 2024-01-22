//
//  EditableText.swift
//
//  Created by : Tomoaki Yagishita on 2024/01/22
//  © 2024  SmallDeskSoftware
//

import SwiftUI

public struct EditableText: View {
    @Binding var value: String
    let alignment: Alignment
    @State private var underEditing = false {
        didSet { if underEditing { fieldFocus = true } }
    }
    @FocusState private var fieldFocus: Bool
    let editClick: Int
    
    public init(value: Binding<String>, editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.alignment = alignment
        self.editClick = editClick
    }
    
    public var body: some View {
        HStack {
            if underEditing {
                TextField("title", text: $value)
                    .focused($fieldFocus)
                    .onSubmit { underEditing.toggle() }
            } else {
                Text(value)
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .contentShape(Rectangle())
                    .onTapGesture(count: editClick, perform: { underEditing.toggle() })
            }
            Button(action: { underEditing.toggle()}, label: { Image(systemName: "pencil") })
        }
        .onChange(of: fieldFocus) { newValue in 
            if !fieldFocus { underEditing = false }
        }
    }
}
#Preview {
    EditableText(value: .constant("Hello world"))
}
