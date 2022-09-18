//
//  GraphData.swift
//
//  Created by : Tomoaki Yagishita on 2021/10/07
//  © 2021  SmallDeskSoftware
//

import Foundation
import SwiftUI
import SDSCGExtension

public class GraphData: ObservableObject {
    @Published var graphDatum: [PolylineGraphDatum]

    public init(_ data: [PolylineGraphDatum], xRange: ClosedRange<Double>) {
        self.graphDatum = data
    }
    
    public func hasEnoughData() -> Bool {
        for datum in graphDatum {
            guard datum.hasEnoughData() else { return false }
        }
        return true
    }
}
