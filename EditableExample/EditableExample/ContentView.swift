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


