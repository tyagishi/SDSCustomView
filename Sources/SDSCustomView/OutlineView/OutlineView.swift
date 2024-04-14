//
//  OutlineView.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/15
//  © 2022  SmallDeskSoftware
//

import Foundation
import SwiftUI
import SDSDataStructure

#if os(macOS)
public protocol OutlineViewDataSourceUpdate {
    func update() -> Bool // return value: reload needed?
}

public protocol OutlineViewCoordinator: NSOutlineViewDataSource, NSOutlineViewDelegate, OutlineViewDataSourceUpdate {}

@available(macOS 12, *)
public struct OutlineView<DataSource: ObservableObject>: NSViewRepresentable {
    @ObservedObject var dataModel: DataSource
    let outlineViewSetup: ((NSOutlineView) -> Void)?
    let scrollViewSetup: ((NSScrollView) -> Void)?
    let coordinator: OutlineViewCoordinator

    public init(_ dataModel: DataSource,
                coordinator: OutlineViewCoordinator,
                outlineViewSetup: ((NSOutlineView) -> Void)? = nil,
                scrollViewSetup: ((NSScrollView) -> Void)? = nil) {
        self.dataModel = dataModel
        self.coordinator = coordinator
        self.outlineViewSetup = outlineViewSetup
        self.scrollViewSetup = scrollViewSetup
    }
    
    public func makeCoordinator() -> OutlineViewCoordinator {
        return self.coordinator
    }
    public func makeNSView(context: Context) -> NSScrollView {
        let outlineView = NSOutlineView()
        outlineView.dataSource = context.coordinator
        outlineView.delegate = context.coordinator
        
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
        if context.coordinator.update() {
            outlineView.reloadData()
        }
        if outlineView.autosaveExpandedItems,
           let autosaveName = outlineView.autosaveName,
           let persistentObjects = UserDefaults.standard.array(forKey: "NSOutlineView Items \(autosaveName)"),
           let itemIds = persistentObjects as? [String] {
            itemIds.forEach {
                let item = outlineView.dataSource?.outlineView?(outlineView, itemForPersistentObject: $0)
                outlineView.expandItem(item)
            }
        }
    }
    
    public typealias NSViewType = NSScrollView
}
#endif
