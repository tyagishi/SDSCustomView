//
//  OutlineView.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/15
//  © 2022  SmallDeskSoftware
//

import Foundation
import SwiftUI

#if os(macOS)
public protocol OutlineViewDataSourceUpdate {
    func update()
}


@available(macOS 12, *)
public struct OutlineView<DataModel: NSOutlineViewDataSource & NSOutlineViewDelegate & ObservableObject & OutlineViewDataSourceUpdate>: NSViewRepresentable {
    @ObservedObject var dataModel: DataModel
    let outlineViewSetup: ((NSOutlineView) -> Void)?
    let scrollViewSetup: ((NSScrollView) -> Void)?

    public init(_ dataModel: DataModel,
                outlineViewSetup: ((NSOutlineView) -> Void)? = nil,
                scrollViewSetup: ((NSScrollView) -> Void)? = nil) {
        self.dataModel = dataModel
        self.outlineViewSetup = outlineViewSetup
        self.scrollViewSetup = scrollViewSetup
    }
    
    public func makeCoordinator() -> Coordinator<DataModel> {
        return Coordinator(dataModel)
    }
    
    
    final public class Coordinator<DataModel: NSOutlineViewDataSource & NSOutlineViewDelegate & OutlineViewDataSourceUpdate>: NSObject {
        var outlineViewData: DataModel

        init(_ data: DataModel) {
            self.outlineViewData = data
        }
        func update() {
            outlineViewData.update()
        }
    }
    
    public func makeNSView(context: Context) -> NSScrollView {
        let outlineView = NSOutlineView()
        outlineView.dataSource = context.coordinator.outlineViewData
        outlineView.delegate = context.coordinator.outlineViewData
        
        outlineViewSetup?(outlineView)

        let scrollView = NSScrollView()
        //scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.documentView = outlineView
        
        scrollViewSetup?(scrollView)

        return scrollView
    }
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let outlineView = nsView.documentView as? NSOutlineView else { return }
        //print(#function)
        context.coordinator.update()
        outlineView.reloadData()
    }
    
    public typealias NSViewType = NSScrollView
}
#endif

