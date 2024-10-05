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
    @State private var indirectValue: V

    public init(value: Binding<V>,
                format: F,
                initMode: EditableMode = .editable,
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.formatStyle = format
        self.editableMode = initMode
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.alignment = alignment
        self.editClick = editClick
        
        indirectValue = value.wrappedValue
        underEditing = (initMode == .edit)
    }
    
    public var body: some View {
        let binding = Binding<V>(get: {
            return indirectValue
        }, set: { newValue in
            indirectValue = newValue
            if !indirectEdit.flag { value = newValue }
        })
        
        HStack {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { editIcon })
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
                Button(action: { toggleUnderEditing() }, label: { editIcon })
            }
        }
        .onChange(of: value, perform: { _ in
            indirectValue = value
        })
        .onChange(of: fieldFocus) { _ in
            if !fieldFocus { toggleUnderEditing(forceTo: false) }
        }
        .onChange(of: textFocus) { _ in
            if textFocus { toggleUnderEditing() }
        }
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

// MARK: valueStyle ViewModifier
public struct EditableViewEditButtonLocationKey: EnvironmentKey {
    public typealias Value = TextAlignment
    public static let defaultValue = TextAlignment.leading
}
extension EnvironmentValues {
    public var editableViewEditButtonLocation: TextAlignment {
        get { return self[EditableViewEditButtonLocationKey.self] }
        set { self[EditableViewEditButtonLocationKey.self] = newValue }
    }
}
extension View {
    public func editButtonLocation(_ alignment: TextAlignment = .leading) -> some View {
        self.environment(\.editableViewEditButtonLocation, alignment)
    }
}

public struct EditableValueForegroundColorKey: EnvironmentKey {
    public typealias Value = Color
    public static var defaultValue: Color = Color.primary
}

extension EnvironmentValues {
    public var editableValueForgroundColorKey: Color {
        get { return self[EditableValueForegroundColorKey.self] }
        set { self[EditableValueForegroundColorKey.self] = newValue }
    }
}

// MARK: indirectEdit ViewModifier
public struct EditableValueIndirectKey: EnvironmentKey {
    public typealias Value = (Bool, Image)
    public static var defaultValue: (Bool, Image) = (false, EditableText.undoIcon)
}

extension EnvironmentValues {
    public var editableValueIndirect: (flag: Bool, image: Image) {
        get { return self[EditableValueIndirectKey.self] }
        set { self[EditableValueIndirectKey.self] = newValue }
    }
}

extension View {
    public func indirectEdit(_ flag: Bool = true, cancelImage: Image = EditableText.undoIcon) -> some View {
        self.environment(\.editableTextIndirect, (flag, cancelImage))
    }
    public func editableValueForegroundColor(_ color: Color) -> some View {
        self.environment(\.editableValueForgroundColorKey, color)
    }
}
