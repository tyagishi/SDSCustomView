//
//  ContentView.swift
//  StatefulButtonExample
//
//  Created by Tomoaki Yagishita on 2026/06/29.
//

import SwiftUI
import SDSCustomView
import SDSViewExtension

struct ContentView: View {
    @State private var buttonState = false
    
    enum ExclusiveState {
        case one
        case two
        case three
        
        var labelString: String {
            switch self {
            case .one:  "One"
            case .two:  "Two"
            case .three: "Three"
            }
        }
    }
    @State private var exclusiveState = ExclusiveState.one
    
    var body: some View {
        VStack {
            StatefulButton($buttonState, onLabel: {
                Text("On").bold()
            }, offLabel: {
                Text("Off")
            }, onChange: { newValue in
                print(newValue)
            })
            .animation(.default, value: buttonState)
            
            HStack {
                exclusiveButton(for: .one)
                exclusiveButton(for: .two)
                exclusiveButton(for: .three)
            }
            .animation(.linear, value: exclusiveState)
        }
        .padding()
    }

    @ViewBuilder
    func exclusiveButton(for state: ExclusiveState) -> some View {
        StatefulButton(Binding<Bool>(get: {
            exclusiveState == state
        }, set: { newValue in
            if newValue == true { exclusiveState = state }
        }), onLabel: { Text(state.labelString)
        }, offLabel: { Text(state.labelString) })
        .modify({ button in
            if exclusiveState == state {
                button//.buttonStyle(.bordered)
                    .bold()
                    .padding(.horizontal, 2)
                    .background(content: {
                        RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.3))
                    })
            } else {
                button//.buttonStyle(.borderless)
                    .padding(.horizontal, 2)
            }
        })
    }
}

#Preview {
    ContentView()
}
