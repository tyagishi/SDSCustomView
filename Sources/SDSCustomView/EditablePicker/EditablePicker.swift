//
//  EditablePicker.swift
//
//  Created by : Tomoaki Yagishita on 2024/08/11
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import SDSViewExtension

public struct EditablePicker<Content: View, Selection: Hashable>: View {
    var undoIcon = Image(systemName: "arrow.uturn.backward")
    
    @Environment(\.editableTextIndirect) var indirectEdit
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation
    @Binding var value: Selection
    let alignment: Alignment
    @State private var underEditing: Bool {
        didSet { if underEditing { fieldFocus = true } }
    }
    let editClick: Int
    let placeholder: String
    let pickerContent: Content
    let formatter: (Selection) -> String
    let editIcon: Image
    let doneIcon: Image
    @State private var indirectValue: Selection

    @FocusState private var fieldFocus: Bool

    public init(value: Binding<Selection>,
                initMode: EditableMode = .editable,
                placeholder: String = "",
                @ViewBuilder pickerContent: @escaping (() -> Content),
                formatter: @escaping ((Selection) -> String),
                editIcon: Image = Image(systemName: "pencil"),
                doneIcon: Image = Image(systemName: "return"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.placeholder = placeholder
        self.pickerContent = pickerContent()
        self.formatter = formatter
        self.editIcon = editIcon
        self.doneIcon = doneIcon
        self.alignment = alignment
        self.editClick = editClick
        
        indirectValue = value.wrappedValue
        underEditing = (initMode == .edit)
    }
    
    public var body: some View {
        let binding = Binding<Selection>(get: {
            return indirectValue
        }, set: { newValue in
            indirectValue = newValue
            if !indirectEdit.flag { value = newValue }
        })
        
        HStack {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { icon })
            }
            if underEditing {
                Picker(selection: binding, content: {
                    pickerContent
                }, label: { Text("Title") }).labelsHidden()
#if os(macOS)
                    .focusable()
#endif
                    .focused($fieldFocus)
                    .onSubmit { toggleUnderEditing() }
                    .modify {
                        if #available(macOS 14, iOS 17, *) {
                            $0.onKeyPress(.return , action: { Task { @MainActor in toggleUnderEditing()}; return .handled })
                        } else {
                            $0
                        }
                    }
                if indirectEdit.flag {
                    Button(action: {
                        indirectValue = value
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
                Button(action: { toggleUnderEditing() }, label: { icon })
            }
        }
        .onChange(of: fieldFocus) { _ in
            if !fieldFocus { toggleUnderEditing(forceTo: false) }
        }
        .onChange(of: value, perform: { _ in
            indirectValue = value
        })
    }
    
    var icon: Image {
        if underEditing { return doneIcon }
        return editIcon
    }
    
    func toggleUnderEditing(forceTo value: Bool? = nil) {
        if let value = value,
           underEditing == value { return }
        if indirectEdit.flag,
           self.value != indirectValue { self.value = indirectValue }
        underEditing.toggle()
    }
}
