//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/22
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import SDSCustomView

struct ContentView: View {
    var body: some View {
        VStack {
            GroupBox(".leading") {
                Group {
                    FixedWidthLabel("123", widthFor: "00000").alignment(.leading)
                    FixedWidthLabel("1", widthFor: "00000").alignment(.leading)
                }
                .border(.red)
            }
            GroupBox(".center") {
                Group {
                    FixedWidthLabel("123", widthFor: "00000").alignment(.center)
                    FixedWidthLabel("1", widthFor: "00000").alignment(.center)
                }
                .border(.red)
            }
            GroupBox(".trailing") {
                Group {
                    FixedWidthLabel("123", widthFor: "00000").alignment(.trailing)
                    FixedWidthLabel("1", widthFor: "00000").alignment(.trailing)
                }
                .border(.red)
            }
        }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
