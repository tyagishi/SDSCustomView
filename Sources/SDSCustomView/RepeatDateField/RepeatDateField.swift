//
//  SwiftUIView.swift
//  SDSCustomView
//
//  Created by Tomoaki Yagishita on 2025/04/14.
//

import SwiftUI
import SDSFoundationExtension

public struct RepeatDateField: View {
    @Binding var isPresented: Bool
    @Binding var dates: [Date]
    @State var startDate: Date
    @State var endDate: Date
    @State var frequency: DateRepeatFrequency = .monthly
    @State var adjustment: DateRepeatAdjustment = .noAdjustment

    public init(isPresented: Binding<Bool>, dates: Binding<[Date]>) {
        self._isPresented = isPresented
        self._dates = dates
        let (start,end) = Calendar.current.yearStartEnd(of: 2025)
        self.startDate = start
        self.endDate = end
    }

    public var body: some View {
        Form {
            DatePicker("Start:", selection: $startDate)
            DatePicker("End  :", selection: $endDate)
            Picker(selection: $frequency, content: {
                ForEach(DateRepeatFrequency.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item)
                }
            }, label: { Text("Frequency") }).fixedSize()
            Picker(selection: $adjustment, content: {
                ForEach(DateRepeatAdjustment.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item)
                }
            }, label: { Text("Adjustment") }).fixedSize()
        }
        .onAppear {
            calcDates()
        }
        .onChange(of: [startDate.description, endDate.description, frequency.rawValue, adjustment.rawValue], perform: { _ in
            calcDates()
        })
    }
    
    func calcDates() {
        dates = Calendar.current.repeatDates(from: startDate, to: endDate, frequency: frequency, adjustment: adjustment)
    }
}
