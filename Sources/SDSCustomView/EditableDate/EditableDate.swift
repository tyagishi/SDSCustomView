//
//  EditableValue.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/15
//  © 2024  SmallDeskSoftware
//

import SwiftUI

private var undoIcon = Image(systemName: "arrow.uturn.backward")

public struct EditableDate<F: ParseableFormatStyle>: View where F.FormatInput == Date, F.FormatOutput == String {
    @Environment(\.editableValueForgroundColorKey) var foregroundColor
    @Environment(\.editableTextIndirect) var indirectEdit
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation
    @Binding var date: Date
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
    @State private var indirectValue: Date

    public init(date: Binding<Date>,
                format: F = Date.FormatStyle(),
                initMode: EditableMode = .editable,
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                editClick: Int = 1,
                displayComponents: DatePickerComponents = [.hourAndMinute, .date],
                alignment: Alignment = .leading) {
        self._date = date
        self.formatStyle = format
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.alignment = alignment
        self.displayComponents = displayComponents
        self.editClick = editClick
        
        indirectValue = date.wrappedValue
        underEditing = (initMode == .edit)
    }
    
    public var body: some View {
        let binding = Binding<Date>(get: {
            if indirectEdit.flag { return indirectValue }
            return date
        }, set: { newValue in
            if indirectEdit.flag { indirectValue = newValue; return }
            date = newValue
        })
        
        HStack(spacing: 2) {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { editIcon })
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
                if indirectEdit.flag {
                    Button(action: {
                        indirectValue = date
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
                Button(action: { toggleUnderEditing() }, label: { editIcon })
            }
        }
        .onChange(of: fieldFocus) { _ in
            if !fieldFocus { toggleUnderEditing() }
        }
        .onChange(of: textFocus) { _ in
            if textFocus { toggleUnderEditing() }
        }
        .onChange(of: date, perform: { _ in
            indirectValue = date
        })
    }
    
    func toggleUnderEditing() {
        if indirectEdit.flag == true,
           underEditing == true {
            date = indirectValue
        }
        indirectValue = date
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
    EditableDate(date: .constant(Date()))
        .indirectEdit()
        .fixedSize()
        .frame(width: 800, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .border(.green)
}
