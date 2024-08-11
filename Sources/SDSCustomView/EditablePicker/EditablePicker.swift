//
//  EditablePicker.swift
//
//  Created by : Tomoaki Yagishita on 2024/08/11
//  © 2024  SmallDeskSoftware
//

import SwiftUI

public struct EditablePicker<Content: View, Selection: Hashable>: View {
    var undoIcon = Image(systemName: "arrow.uturn.backward")
    
    @Environment(\.editableTextIndirect) var indirectEdit
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation
    @Binding var value: Selection
    let alignment: Alignment
    @State private var underEditing = false {
        didSet { if underEditing { fieldFocus = true } }
    }
    let editClick: Int
    let placeholder: String
    let pickerContent: Content
    let formatter: (Selection) -> String
    let editIcon: Image
    @State private var indirectText: Selection

    @FocusState private var fieldFocus: Bool

    public init(value: Binding<Selection>,
                placeholder: String = "",
                @ViewBuilder pickerContent: @escaping (() -> Content),
                formatter: @escaping ((Selection) -> String),
                editIcon: Image = Image(systemName: "pencil"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.placeholder = placeholder
        self.pickerContent = pickerContent()
        self.formatter = formatter
        self.editIcon = editIcon
        self.alignment = alignment
        self.editClick = editClick
        
        indirectText = value.wrappedValue
    }
    
    public var body: some View {
        let binding = Binding<Selection>(get: {
            if indirectEdit.flag { return indirectText }
            return value
        }, set: { newText in
            if indirectEdit.flag { indirectText = newText; return }
            value = newText
        })
        
        HStack {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { editIcon })
            }
            if underEditing {
                Picker(selection: binding, content: {
                    pickerContent
                }, label: { Text("Title") }).labelsHidden()
                    .focused($fieldFocus)
                    .onSubmit { toggleUnderEditing() }
                if indirectEdit.flag {
                    Button(action: {
                        indirectText = value
                        underEditing.toggle()}, label: { indirectEdit.image })
                }
            } else {
                Text(formatter(value))
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .contentShape(Rectangle())
                    .onTapGesture(count: editClick, perform: {
                        guard editClick < Int.max else { return }
                        toggleUnderEditing()
                    })
            }
            if editButtonLocation == .trailing,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { editIcon })
            }
        }
        .onChange(of: fieldFocus) { _ in
            if !fieldFocus { underEditing = false }
        }
    }
    
    func toggleUnderEditing() {
        if indirectEdit.flag == true,
           underEditing == true {
            value = indirectText
        }
        underEditing.toggle()
    }
}
