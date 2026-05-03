//
//  EditableTokenExample.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/05/03.
//

import SwiftUI
import SDSCustomView

class TestElement: ObservableObject {
    var tags: [String] = []

    init(tags: [String]) {
        self.tags = tags
    }
}

struct EditableTokenExample: View {
    let allTokens = ["Hello", "World", "Hallo", "Konnichiwa"]
    @State private var tokens: [String] = ["Hello"]
    @StateObject private var element = TestElement(tags: ["Hello"])
    @State private var text1 = "Text1"
    var body: some View {
        VStack {
            Group {
                let getSet = (getter: {
                    tokens
                }, setter: { strings in
                    tokens = strings
                })
                EditableToken(getSet: getSet, selectableTokens: allTokens)
                Text("tokens value: \(tokens.joined(separator: ","))").focusable()
                Button(action: {
                    if !tokens.contains("Konnichiwa") {
                        tokens.append("Konnichiwa")
                    }
                }, label: { Text("Add Konnichiwa") })
            }
            Group {
                let getSet = (getter: {
                    element.tags
                }, setter: { strings in
                    element.tags = strings
                })
                EditableToken(getSet: getSet, selectableTokens: allTokens)
                Text("tokens value: \(element.tags.joined(separator: ","))").focusable()

                Button(action: {
                    if !element.tags.contains("Konnichiwa") {
                        element.objectWillChange.send()
                        element.tags.append("Konnichiwa")
                    }
                }, label: { Text("Add Konnichiwa") })
            }
            //.indirectEdit()
        }

    }
}
