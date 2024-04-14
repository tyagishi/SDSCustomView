//
//  LongPressableButton.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/23
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public struct LongPressableButton<Label>: View  where Label: View {
    var tapAction: (() -> Void)?
    var longPressDetected: (() -> Void)? = nil
    var longPressAction: (() -> Void )?
    var label: (() -> Label)
    @State private var longPressed = false

    public init(tapAction: (() -> Void)? = nil,
                longPressDetected: (() -> Void)? = nil,
                longPressAction: (() -> Void)? = nil, label: @escaping (() -> Label) ) {
        self.tapAction = tapAction
        self.longPressDetected = longPressDetected
        self.longPressAction = longPressAction
        self.label = label
    }

    public var body: some View {
        Button(action: {
            if longPressed {
                longPressAction?()
                longPressed = false
            } else {
                tapAction?()
            }
        }, label: {
            label()
        })
            .simultaneousGesture(
                LongPressGesture().onEnded { _ in
                    longPressDetected?()
                    longPressed = true
                }
            )
            .padding()
    }
}
struct LongPressableButton_Previews: PreviewProvider {
    static var previews: some View {
        LongPressableButton(label: {
        Text("Hello")})
    }
}
