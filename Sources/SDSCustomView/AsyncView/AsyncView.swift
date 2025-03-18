//
//  AsyncView.swift
//
//  Created by : Tomoaki Yagishita on 2024/04/16
//  © 2024  SmallDeskSoftware
//

import Combine
import SwiftUI
import SDSViewExtension

@available(iOS 15, macOS 12, *)
public struct AsyncView<T: Sendable, PV: View, DV: View>: View {
    let content: (T) -> DV
    let placeholder: PV
    let dataProvider: () async -> T
    let updateProvider: AnyPublisher<T,Never>?

    @State private var currentData: T? = nil

    public init(content: @escaping (T) -> DV,
                placeholder: () -> PV,
                dataProvider: @escaping () async -> T,
                updateProvider: AnyPublisher<T,Never>? = nil) {
        self.content = content
        //self.updatePub = update
        self.placeholder = placeholder()
        self.dataProvider = dataProvider
        self.updateProvider = updateProvider
    }
    
    public var body: some View {
        Group {
            if let currentData = currentData {
                content(currentData)
            } else {
                placeholder
            }
        }
        .task {
            let providedData = await dataProvider()
            currentData = providedData
        }
        .optionalOnReceive(updateProvider?.receive(on: RunLoop.main), perform: { value in
            currentData = value
        })
    }
}
