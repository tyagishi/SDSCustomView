//
//  EditableValue.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/15
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import SDSViewExtension

private var undoIcon = Image(systemName: "arrow.uturn.backward")

@available(iOS 15, macOS 12, *)
public struct EditableDate<F: ParseableFormatStyle>: View where F.FormatInput == Date, F.FormatOutput == String {
    @Environment(\.editableValueForgroundColorKey) var foregroundColor
    @Environment(\.editableTextIndirect) var indirectEdit
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation
    @Binding var value: Date
    let formatStyle: F
    let alignment: Alignment
    let displayComponents: DatePickerComponents
    @State private var underEditing: Bool {
        didSet { if underEditing { fieldFocus = true } }
    }
    @FocusState private var fieldFocus: Bool
    @FocusState private var textFocus: Bool
    let editClick: Int
    let placeholder: String
    let editIcon: Image
    let doneIcon: Image
    @State private var indirectValue: Date

    public init(date: Binding<Date>,
                format: F = Date.FormatStyle(),
                initMode: EditableMode = .editable,
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                doneIcon: Image = Image(systemName: "return"),
                editClick: Int = 1,
                displayComponents: DatePickerComponents = [.hourAndMinute, .date],
                alignment: Alignment = .leading) {
        self._value = date
        self.formatStyle = format
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.doneIcon = doneIcon
        self.alignment = alignment
        self.displayComponents = displayComponents
        self.editClick = editClick
        
        indirectValue = date.wrappedValue
        underEditing = (initMode == .edit)
    }
    
    public var body: some View {
        let binding = Binding<Date>(get: {
            return indirectValue
        }, set: { newValue in
            indirectValue = newValue
            if !indirectEdit.flag { value = newValue }
        })
        
        HStack(spacing: 2) {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { icon })
            }
            if underEditing {
                DatePicker(selection: binding,
                           displayedComponents: displayComponents,
                           label: { Text("") })
                .focused($fieldFocus)
                .foregroundStyle(foregroundColor)
                .labelsHidden()
                .onSubmit { toggleUnderEditing() }
                .multilineTextAlignment(textAlignment(alignment))
                .modify {
                    if #available(macOS 14, iOS 17, *) {
                        $0.onKeyPress(.return , action: { Task { @MainActor in toggleUnderEditing()}; return .handled })
                    } else {
                        $0
                    }
                }
                if indirectEdit.flag {
                    Button(action: {
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
    
    func textAlignment(_ alignment: Alignment) -> TextAlignment {
        switch alignment {
        case .leading:   return TextAlignment.leading
        case .center:    return TextAlignment.center
        case .trailing:  return TextAlignment.trailing
        default:         return TextAlignment.leading
        }
    }
}
