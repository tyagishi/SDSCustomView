//
//  FixedWidthLabel.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/18
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public struct FixedWidthLabel: View {
    @Environment(\.fixedWidthLabelAlignment) var alignment
    let template: String
    let label: String
    public init(_ label: String,_ template: String) {
        self.label = label
        self.template = template
    }
    public var body: some View {
        Text(template)
            .hidden()
            .overlay(
                Text(label)
                    .frame(maxWidth: .infinity, alignment: alignment)
            )
    }
}

extension FixedWidthLabel {
    public func alignment(_ alignment: Alignment) -> some View {
        self.environment(\.fixedWidthLabelAlignment, alignment)
    }
}

public struct FixedWidthLabelAlignment: EnvironmentKey {
    public typealias Value = Alignment
    static public var defaultValue: Alignment = .center
}

extension EnvironmentValues {
    var fixedWidthLabelAlignment: Alignment {
        get {
            return self[FixedWidthLabelAlignment.self]
        }
        set {
            self[FixedWidthLabelAlignment.self] = newValue
        }
    }
}

struct FixedWidthLabel_Previews: PreviewProvider {
    static var previews: some View {
        FixedWidthLabel("123", "00000")
            .alignment(.center)
    }
}
