//
//  EditableTextBuffered.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/12
//  © 2024  SmallDeskSoftware
//

import SwiftUI

public struct EditableTextBuffered: View {
    @Binding var value: String
    let alignment: Alignment
    @State private var underEditing = false {
        didSet { if underEditing { fieldFocus = true } }
    }
    @FocusState private var fieldFocus: Bool
    let editClick: Int
    let placeholder: String
    let editIcon: Image
    let cancelIcon: Image
    
    @State private var editString: String
    @State private var textFieldBackgroundColor = Color(nsColor: .textBackgroundColor)
    
    public init(value: Binding<String>,
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                cancelIcon: Image = Image(systemName: "xmark"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.cancelIcon = cancelIcon
        self.alignment = alignment
        self.editClick = editClick
        editString = value.wrappedValue
    }
    
    public var body: some View {
        HStack {
            if underEditing {
                TextField(placeholder, text: $editString)
                    .focused($fieldFocus)
                    .background(textFieldBackgroundColor)
                    .onSubmit {
                        value = editString
                        underEditing.toggle()
                    }
                Button(action: {
                    editString = value
                    underEditing.toggle()}, label: { cancelIcon })
            } else {
                Text(editString)
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .contentShape(Rectangle())
                    .onTapGesture(count: editClick, perform: { underEditing.toggle() })
            }
            Button(action: { underEditing.toggle() }, label: { editIcon })
        }
        .onChange(of: fieldFocus) { _ in
            if !fieldFocus { underEditing = false }
        }
        .onChange(of: [editString, value]) { _ in
            textFieldBackgroundColor = Color(nsColor: ((editString == value) ? .textBackgroundColor : .red))
        }
    }
}
#Preview {
    EditableText(value: .constant("Hello world"))
}
