//
//  EditableDateExample.swift
//  EditableExample
//
//  Created by Tomoaki Yagishita on 2026/03/31.
//


import SwiftUI
import SDSCustomView

struct EditableDateExample: View {
    @State private var date = Date()
    var body: some View {
        VStack {
            Text("internal value: \(date.formatted(date: .numeric, time: .standard))").focusable()
            HStack {
                Text("no option")
                EditableDate(date: $date, displayComponents: [.date])
            }
            HStack {
                Text("indirect")
                EditableDate(date: $date, displayComponents: [.date])
                    .indirectEdit()
            }
            HStack {
                Text(".hourAndMinute")
                EditableDate(date: $date, displayComponents: [.hourAndMinute])
            }
            HStack {
                Text("indirect")
                Text(".hourAndMinute")
                EditableDate(date: $date, displayComponents: [.hourAndMinute])
                    .indirectEdit()
            }
        }
        .onChange(of: date, {
            print("date is changed")
        })

    }
}
