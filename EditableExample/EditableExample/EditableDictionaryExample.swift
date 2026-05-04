//
//  EditableDictionaryExample.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/05/04.
//


import SwiftUI
import SDSCustomView

struct EditableDictionaryExample: View {
    @State private var strStrDic = ["Hello": "World",
                                    "こんにちわ": "せかい" ]
    @State private var strDecDic = ["Cost1": Decimal(1000),
                                    "Cost2": Decimal(525) ]
    
    var body: some View {
        VStack {
            GroupBox("EditableStringStringDictionary", content: {
                EditableStringStringDictionary($strStrDic)
                    .fixedSize(horizontal: true, vertical: false)
            })
            GroupBox("EditableStringDictionary", content: {
                EditableStringDictionary($strDecDic,
                                         formatstyle: Decimal.FormatStyle.Currency(code: "JPY"), newDefaultValue: .zero)
                .fixedSize(horizontal: true, vertical: false)
            })
        }
    }
}