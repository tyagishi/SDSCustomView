//
//  TableView.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/25
//  © 2022  SmallDeskSoftware
//
import SwiftUI

#if os(macOS)
@available(macOS 12, *)
public struct TableView<DataModel: NSTableViewDataSource & NSTableViewDelegate & ObservableObject>: NSViewRepresentable {
    @ObservedObject var dataModel: DataModel
    let tableViewSetup: ((NSTableView) -> Void)?
    let scrollViewSetup: ((NSScrollView) -> Void)?

    public init(_ dataModel: DataModel,
                tableViewSetup: ((NSTableView) -> Void)? = nil,
                scrollViewSetup: ((NSScrollView) -> Void)? = nil) {
        self.dataModel = dataModel
        self.tableViewSetup = tableViewSetup
        self.scrollViewSetup = scrollViewSetup
    }
    
    public func makeCoordinator() -> Coordinator<DataModel> {
        return Coordinator(dataModel)
    }
    
    final public class Coordinator<DataModel: NSTableViewDataSource & NSTableViewDelegate & ObservableObject>: NSObject {
        var dataModel: DataModel
        init(_ dataModel: DataModel) {
            self.dataModel = dataModel
        }
    }
    
    public func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()
        tableView.dataSource = context.coordinator.dataModel
        tableView.delegate = context.coordinator.dataModel
        
        tableViewSetup?(tableView)
        
        let scrollView = NSScrollView()
        scrollView.documentView = tableView

        scrollViewSetup?(scrollView)
        
        return scrollView
    }
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tableView = nsView.documentView as? NSTableView else { return }
        tableView.reloadData()
    }
    
    public typealias NSViewType = NSScrollView
}
#endif
