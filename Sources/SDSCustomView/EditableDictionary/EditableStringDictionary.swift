//
//  EditableStringDictionary.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/05/04.
//

import SwiftUI

@available(macOS 13, iOS 16, *)
public struct EditableStringDictionary<V, F>: View where F: ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String, V: Equatable {
    @Binding var localDictionary: [String: V]
    let formatstyle: F
    
    public init(_ localDictionary: Binding<[String: V]>, formatstyle: F, newDefaultValue: V) {
        self._localDictionary = localDictionary
        self.formatstyle = formatstyle
        self.newValue = newDefaultValue
    }
    
    @State private var newKey: String = ""
    @State private var newValue: V
    public var body: some View {
        VStack {
            Grid {
                ForEach(Array(localDictionary.keys.sorted()), id: \.self, content: { key in
                    GridRow {
                        Button(action: { localDictionary[key] = nil },
                               label: { Image(systemName: "trash").frame(maxHeight: .infinity) }).gridCellUnsizedAxes(.vertical)
                        Text(key)
                            .padding(.leading, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        EditableValue(value: Binding<V>(get: { localDictionary[key]!},
                                                        set: { newValue in localDictionary[key] = newValue }),
                                      format: formatstyle)
                    }
                })
                GridRow {
                    Button(action: {
                        localDictionary[newKey] = newValue
                        newKey = ""
                        newValue = newValue
                    }, label: { Image(systemName: "plus").frame(maxHeight: .infinity) }).gridCellUnsizedAxes(.vertical)
                        .disabled(newKey.isEmpty)
                        .disabled(localDictionary.keys.contains(newKey))
                    TextField("NewKey", text: $newKey)
                        .multilineTextAlignment(.leading)
                    TextField("NewValue", value: $newValue, format: formatstyle)
                }
            }
        }
        .editButtonLocation(.trailing)
    }
}
