//
//  EditableText.swift
//
//  Created by : Tomoaki Yagishita on 2024/01/22
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import OSLog

extension OSLog {
    //fileprivate static var log = Logger(subsystem: "com.smalldesksoftware.sdscustomview", category: "EditableText")
    fileprivate static var log = Logger(.disabled)
}

public struct EditableText: View {
    public static var undoIcon = Image(systemName: "arrow.uturn.backward")
    
    @Environment(\.editableTextIndirect) var indirectEdit
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation
    @Binding var value: String
    let alignment: Alignment
    @State private var underEditing = false {
        didSet { if underEditing { fieldFocus = true } }
    }
    let editClick: Int
    let placeholder: String
    let editIcon: Image
    @State private var indirectText: String

    @FocusState private var fieldFocus: Bool

    public init(value: Binding<String>,
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self._value = value
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.alignment = alignment
        self.editClick = editClick
        
        indirectText = value.wrappedValue
    }
    
    public var body: some View {
        let binding = Binding<String>(get: {
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
                TextField(placeholder,
                          text: binding)
                    .focused($fieldFocus)
                    .onSubmit { toggleUnderEditing() }
                if indirectEdit.flag {
                    Button(action: {
                        indirectText = value
                        underEditing.toggle()}, label: { indirectEdit.image })
                }
            } else {
                Text(value)
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
        indirectText = value
        underEditing.toggle()
    }
}
#Preview {
    EditableText(value: .constant("Hello world"))
}

// MARK: indirectEdit ViewModifier
struct EditableTextIndirectKey: EnvironmentKey {
    typealias Value = (Bool, Image)
    
    static var defaultValue: (Bool, Image) = (false, EditableText.undoIcon)
}

extension EnvironmentValues {
    public var editableTextIndirect: (flag: Bool, image: Image) {
        get { return self[EditableTextIndirectKey.self] }
        set { self[EditableTextIndirectKey.self] = newValue }
    }
}

extension EditableText {
    public func indirectEdit(_ flag: Bool = true, cancelImage: Image = EditableText.undoIcon) -> some View {
        self.environment(\.editableTextIndirect, (flag, cancelImage))
    }
}
