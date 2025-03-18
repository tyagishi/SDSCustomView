//
//  SwiftUIView.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/11
//  © 2024  SmallDeskSoftware
//

import SwiftUI

@available(iOS 15, macOS 12, *)
public struct TokenView: View {
    let tokens: [String]
    
    let cornerRadius = 3.0
    let lineWidth = 0.5
    
    public init(_ tokens: [String]) {
        self.tokens = tokens
    }
    
    public var body: some View {
        // TODO: should be able to custom shape stype
        HStack {
            ForEach(tokens, id: \.self) { token in
                Text(token)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 1)
                    .background(.blue.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.cyan, lineWidth: lineWidth)
                    )
            }
        }
    }
}
