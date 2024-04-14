//
//  StatefulButton.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/14
//  © 2024  SmallDeskSoftware
//

import SwiftUI

public struct StatefulButton<OnLabel: View, OffLabel: View>: View {
    @Binding var bValue: Bool
    var trueLabel: OnLabel
    var falseLabel: OffLabel
    var onChange: ((Bool) -> Void)?

    public init(_ value: Binding<Bool>,
                @ViewBuilder onLabel: () -> OnLabel,
                @ViewBuilder offLabel: () -> OffLabel,
                onChange: ((Bool) -> Void)? = nil) {
        self._bValue = value
        self.trueLabel = onLabel()
        self.falseLabel = offLabel()
        self.onChange = onChange
    }

    public var body: some View {
        Button(action: {
            self.bValue.toggle()
            onChange?(self.bValue)
        }, label: {
            if bValue {
                trueLabel
            } else {
                falseLabel
            }
        })
    }
}
