//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/16
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import Combine
import SDSCustomView

struct ContentView: View {
    let updateProvider = PassthroughSubject<Int,Never>()

    var body: some View {
        VStack {
            AsyncView(content: { (value: Int) in
                Text(String(value))
            }, placeholder: {
                ProgressView()
            }, dataProvider: {
                return await longCalc()
            }, updateProvider: updateProvider.eraseToAnyPublisher())
            Button(action: {
                updateProvider.send((1...10).randomElement()!)
            }, label: { Text("Random") })
        }
    }
    
    func longCalc() async -> Int {
        // after long calculation
        try? await Task.sleep(for: .seconds(3))
        return 2
    }
}

#Preview {
    ContentView()
}
