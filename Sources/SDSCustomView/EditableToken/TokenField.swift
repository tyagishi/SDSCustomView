//
//  TokenField.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/10
//  © 2024  SmallDeskSoftware
//

import Foundation
import SwiftUI
import OSLog

extension OSLog {
    //fileprivate static var log = Logger(subsystem: "com.smalldesksoftware.sdscustomview", category: "TokenField")
    fileprivate static var log = Logger(.disabled)
}

public typealias EditableTokenGet = () -> [String]
public typealias EditableTokenGetSet = (getter: () -> [String], setter: ([String]) -> Void)

#if os(macOS)
public struct TokenField: NSViewRepresentable {
    public typealias NSViewType = NSTokenField
    let getSet: EditableTokenGetSet
    let tokenFieldDelegate: TokenFieldDelegate
    let placeholder: String?

    public init(getSet: EditableTokenGetSet,
                selectableTokens: [String], placeholder: String? = nil) {
        OSLog.log.debug(#function)
        self.getSet = getSet
        self.tokenFieldDelegate = TokenFieldDelegate(selectableTokens: selectableTokens, getSet: getSet)
        self.placeholder = placeholder
    }

    public func makeNSView(context: Context) -> NSTokenField {
        OSLog.log.debug(#function)
        let tokenField = NSTokenField()
        tokenField.objectValue = getSet.getter()
        tokenField.delegate = tokenFieldDelegate
//        tokenField.placeholderString = placeholder
        return tokenField
    }
    
    public func updateNSView(_ tokenField: NSTokenField, context: Context) {
        // OSLog.log.debug(#function)
        tokenField.objectValue = getSet.getter()
        tokenField.delegate = tokenFieldDelegate
//        tokenField.placeholderString = placeholder
    }
}
#else
struct TokenField: View {
//    let element: any Taggable
//    let selectableTags: [any TagProtocol]

    var body: some View {
        fatalError("not implemented yet")
        TextField("Tags", text: .constant("Tag1, Tag2"))
    }
}
#endif
