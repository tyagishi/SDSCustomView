//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2024/08/20
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import SDSCustomView

struct ContentView: View {
    var body: some View {
        TabView {
            EditableDictionaryExample()
                .tabItem({ Text("EditableDictionary")})
            EditableTokenExample()
                .tabItem({ Text("EditableToken")})
            EditableTextExample()
                .tabItem({ Text("EditableText")})
            EditableValueExample()
                .tabItem({ Text("EditableValue")})
            EditableDateExample()
                .tabItem({ Text("EditableDate")})
            EditablePickerExample()
                .tabItem({ Text("EditablePickerExample")})
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct EditableDictionaryExample: View {
    @State private var strStrDic = ["Hello": "World",
                                    "こんにちわ": "せかい" ]
    @State private var strDecDic = ["Cost1": Decimal(1000),
                                    "Cost2": Decimal(525) ]
    
    var body: some View {
        VStack {
            Text("EditableDictionary")
            EditableStringStringDictionary(localDictionary: $strStrDic)
            EditableStringDecimalDictionary($strDecDic,
                                            formatstyle: Decimal.FormatStyle.Currency(code: "JPY"), newDefaultValue: .zero)
        }
    }
        
}

struct EditableStringStringDictionary: View {
    @Binding var localDictionary: Dictionary<String, String>
    
    @State private var newKey: String = ""
    @State private var newValue: String = ""
    var body: some View {
        VStack {
            ForEach(Array(localDictionary.keys), id: \.self, content: { key in
                HStack {
                    Button(action: { localDictionary[key] = nil },
                           label: { Image(systemName: "minus").frame(maxHeight: .infinity) })
                    .frame(maxHeight: .infinity)
                    Text(key)
                    EditableText(value: Binding<String> (get: { localDictionary[key]! },
                                                         set: { newValue in
                        localDictionary[key] = newValue
                    }))
                }
            })
            HStack {
                TextField("NewKey", text: $newKey)
                TextField("NewValue", text: $newValue)
                Button(action: {
                    localDictionary[newKey] = newValue
                }, label: { Text("Add") })
                    .disabled(newKey.isEmpty).disabled(newValue.isEmpty)
                    .disabled(localDictionary.keys.contains(newKey))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .editButtonLocation(.trailing)
    }
}


public struct EditableStringDecimalDictionary<V, F>: View where F: ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String, V: Equatable {
    @Binding var localDictionary: Dictionary<String, V>
    let formatstyle: F
    
    public init(_ localDictionary: Binding<Dictionary<String, V>>, formatstyle: F, newDefaultValue: V) {
        self._localDictionary = localDictionary
        self.formatstyle = formatstyle
        self.newValue = newDefaultValue
    }
    
    @State private var newKey: String = ""
    @State private var newValue: V
    public var body: some View {
        VStack {
            ForEach(Array(localDictionary.keys), id: \.self, content: { key in
                HStack {
                    Button(action: { localDictionary[key] = nil },
                           label: { Image(systemName: "minus")
                            .frame(maxHeight: .infinity)
                    })
                    Text(key)
                        .frame(maxHeight: .infinity)
                    EditableValue(value: Binding<V>(get: { localDictionary[key]!},
                                                          set: { newValue in localDictionary[key] = newValue }),
                                  format: formatstyle)
                    .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
            })
            HStack {
                TextField("NewKey", text: $newKey)
                TextField("NewValue", value: $newValue, format: formatstyle)
                Button(action: {
                    localDictionary[newKey] = newValue
                }, label: { Text("Add") })
                    .disabled(newKey.isEmpty)
                    .disabled(localDictionary.keys.contains(newKey))
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .editButtonLocation(.trailing)
    }
}

