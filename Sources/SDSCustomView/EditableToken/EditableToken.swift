//
//  EditableToken.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/15
//  © 2024  SmallDeskSoftware
//

import SwiftUI

// NOTE: not yet used...

// swiftlint:disable:next identifier_name
let editableTokenFocusLooseRequestNotification = Notification.Name("EditableTokenFocusLooseRequestNotification")

@available(iOS 15, macOS 12, *)
public struct EditableToken: View {
    public static var undoIcon = Image(systemName: "arrow.uturn.backward")
    @Environment(\.editableViewEditButtonLocation) var editButtonLocation

    let getSet: EditableTokenGetSet
    let selectableTokens: [String]
    let placeholder: String
    let editIcon: Image
    let editClick: Int
    let alignment: Alignment

    @State private var underEditing = false {
        didSet { if underEditing { fieldFocus = true } }
    }
    @FocusState private var fieldFocus: Bool

    public init(getSet: EditableTokenGetSet,
                selectableTokens: [String],
                placeholder: String = "",
                editIcon: Image = Image(systemName: "pencil"),
                editClick: Int = 1, alignment: Alignment = .leading) {
        self.getSet = getSet
        self.selectableTokens = selectableTokens
        
        self.placeholder = placeholder
        self.editIcon = editIcon
        self.alignment = alignment
        self.editClick = editClick
    }
    
    public var body: some View {
        HStack {
            if editButtonLocation == .leading,
               editClick < Int.max {
                Button(action: { toggleUnderEditing() }, label: { editIcon })
            }
            if underEditing {
                TokenField(getSet: getSet, selectableTokens: selectableTokens)
                    .focused($fieldFocus)
                    .onSubmit { toggleUnderEditing() }
            } else {
                TokenView(getSet.getter())
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .contentShape(Rectangle())
                    .onTapGesture(count: editClick, perform: { toggleUnderEditing() })
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
            if !fieldFocus { underEditing = false }
        }
    }
    
    func toggleUnderEditing() {
        underEditing.toggle()
    }
}
