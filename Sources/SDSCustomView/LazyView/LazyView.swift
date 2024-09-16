//
//  LazyView.swift
//
//  Created by : Tomoaki Yagishita on 2024/09/16
//  © 2024  SmallDeskSoftware
//

import SwiftUI

public static accessCheck: Int = 4

public struct LazyView<Content: View>: View {
    let buildContent: () -> Content

    public init(_ @ViewBuilder buildContent: @autoclosure @escaping() -> Content ) {
        self.buildContent = buildContent
    }

    @ViewBuilder
    public var body: some View {
        buildContent()
    }
}
