//
//  EditableValue.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/15
//  © 2024  SmallDeskSoftware
//

import SwiftUI

private var undoIcon = Image(systemName: "arrow.uturn.backward")

public struct EditableValue<V: Equatable, F: ParseableFormatStyle>: View where F.FormatInput == V, F.FormatOutput == String {
    typealias Value = V
    @Environment(\.editableValueForgroundColorKey) var foregroundColor
    @Environment(\.editableTextIndirect) var indirectEdit
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation
    @Binding var value: V
    let formatStyle: F
    let validate: ((V) -> Bool)?
    let editableMode: EditableMode
    let alignment: Alignment
    @State private var underEditing: Bool {
        didSet { if underEditing { fieldFocus = true } }
    }
    @FocusState private var fieldFocus: Bool
    @FocusState private var textFocus: Bool
    let editClick: Int
    let placeholder: String
    let editIcon: Image
    let doneIcon: Image
    @State private var indirectValue: V

    public init(value: Binding<V>,
                format: F,
                validate: ((V) -> Bool)? = nil, // false then ignore input
                initMode: EditableMode = .editable,
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                doneIcon: Image = Image(systemName: "return"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.validate = validate
        self.formatStyle = format
        self.editableMode = initMode
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.doneIcon = doneIcon
        self.alignment = alignment
        self.editClick = editClick
        
        indirectValue = value.wrappedValue
        underEditing = (initMode == .edit)
    }
    
    public var body: some View {
        let binding = Binding<V>(get: {
            return indirectValue
        }, set: { newValue in
            if validate?(newValue) == false { return }
            indirectValue = newValue
            if !indirectEdit.flag { value = newValue }
        })
        
        HStack {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { icon })
            }
            if underEditing {
                TextField(placeholder, value: binding, format: formatStyle)
                    .focused($fieldFocus)
                    .foregroundStyle(foregroundColor)
                    .onSubmit { toggleUnderEditing() }
                    .multilineTextAlignment(textAlignment(alignment))
                if indirectEdit.flag {
                    Button(action: {
                        indirectValue = value
                        underEditing.toggle()}, label: { indirectEdit.image })
                }
            } else {
                Text(formatStyle.format(indirectValue))
                    .foregroundStyle(foregroundColor)
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .contentShape(Rectangle())
                    .onTapGesture(count: editClick, perform: { toggleUnderEditing() })
                    .focused($textFocus)
                #if os(macOS)
                    .focusable()
                #endif
            }
            if editButtonLocation == .trailing,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { icon })
            }
        }
        .onChange(of: value, perform: { newValue in
            indirectValue = newValue
        })
        .onChange(of: fieldFocus) { _ in
            if !fieldFocus { toggleUnderEditing(forceTo: false) }
        }
        .onChange(of: textFocus) { _ in
            if textFocus { toggleUnderEditing() }
        }
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
    
    func textAlignment(_ alignment: Alignment) -> TextAlignment {
        switch alignment {
        case .leading:   return TextAlignment.leading
        case .center:    return TextAlignment.center
        case .trailing:  return TextAlignment.trailing
        default:         return TextAlignment.leading
        }
    }
}
#Preview {
    EditableText(value: .constant("Hello world"))
}

