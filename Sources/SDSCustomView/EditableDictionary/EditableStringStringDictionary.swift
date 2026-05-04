//
//  EditableStringStringDictionary.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/05/04.
//

import SwiftUI

@available(macOS 13, iOS 16, *)
public struct EditableStringStringDictionary: View {
    @Binding var localDictionary: [String: String]
    
    @State private var newKey: String = ""
    @State private var newValue: String = ""
    
    public init(_ localDictionary: Binding<[String: String]>) {
        self._localDictionary = localDictionary
    }
    
    public var body: some View {
        Grid {
            ForEach(Array(localDictionary.keys), id: \.self, content: { key in
                GridRow {
                    Button(action: { localDictionary[key] = nil },
                           label: { Image(systemName: "trash").frame(maxHeight: .infinity) }).gridCellUnsizedAxes(.vertical)
                    Text(key)
                    EditableText(value: Binding<String>(get: { localDictionary[key]! },
                                                        set: { newValue in
                        localDictionary[key] = newValue
                    }))
                }
            })
            GridRow {
                Button(action: {
                    localDictionary[newKey] = newValue
                    newKey = ""
                    newValue = ""
                }, label: { Image(systemName: "plus").frame(maxHeight: .infinity) }).gridCellUnsizedAxes(.vertical)
                    .disabled(newKey.isEmpty).disabled(newValue.isEmpty)
                    .disabled(localDictionary.keys.contains(newKey))
                TextField("NewKey", text: $newKey)
                TextField("NewValue", text: $newValue)
            }
        }
        .editButtonLocation(.trailing)
    }
}
