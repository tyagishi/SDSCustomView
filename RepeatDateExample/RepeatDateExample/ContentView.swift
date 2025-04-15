//
//  ContentView.swift
//  RepeatDateExample
//
//  Created by Tomoaki Yagishita on 2025/04/14.
//

import SwiftUI
import SDSFoundationExtension
import SDSCustomView

struct ContentView: View {
    @State private var dateText = ""
    @State private var showDialog = false
    @State private var dates: [Date] = []

    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var frequency: DateRepeatFrequency = .monthly
    @State var adjustment: DateRepeatAdjustment = .noAdjustment

    var body: some View {
        HStack {
            ScrollView(content: {
                Text(dateText).monospaced()
                    .padding()
            })
            RepeatDateField(isPresented: $showDialog, dates: $dates)
        }
        .onChange(of: dates, {
            dateText = dates.map({ $0.formatted(date: .numeric, time: .shortened) }).joined(separator: "\n")
        })
        .padding()
    }
}

#Preview {
    ContentView()
}
