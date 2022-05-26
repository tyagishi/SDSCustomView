//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/15
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import SDSCustomView

struct ContentView: View {
    @StateObject var dataSource: DataSource = DataSource()
    var body: some View {
        VStack {
            OutlineView(dataSource, outlineViewSetup: { outlineView in
                let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("1st"))
                column1.title = "1st"
                outlineView.addTableColumn(column1)

                let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("2nd"))
                column2.title = "2nd"
                outlineView.addTableColumn(column2)

                let column3 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("3rd"))
                column3.title = "3rd"
                outlineView.addTableColumn(column3)
                
                outlineView.registerForDraggedTypes([.string])
            }, scrollViewSetup: {_ in })
        }
        .padding()
    }
}

class DataSource: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate, ObservableObject {
    @Published var data = TreeNode(value: "root", children: [ TreeNode(value: "Child1"),
                                                              TreeNode(value: "Child2", children: [ TreeNode(value: "GrandChild1"),
                                                                                                    TreeNode(value: "GrandChild2")]),
                                                              TreeNode(value: "Child3", children: [ TreeNode(value: "GrandChildA"),
                                                                                                    TreeNode(value: "GrandChildB")
                                                                                                  ])
                                                            ] )
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let element = item as? TreeNode<String> else { return data.children.count }
        return element.children.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let element = item as? TreeNode<String> else { return (data.children.count > 0) }
        return (element.children.count > 0)
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let element = item as? TreeNode<String> else { return data.children[index] }
        return element.children[index]
    }
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        guard let element = item as? TreeNode<String> else { return "unknown" }
        return element.value
    }
    
    // MARK: D&D -- drag
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let element = item as? TreeNode<String> else { return nil }
        
        let pbItem = NSPasteboardItem()
        pbItem.setString(element.value, forType: NSPasteboard.PasteboardType.string)
        return pbItem
    }

    // MARK: D&D -- drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard let dragName = info.draggingPasteboard.string(forType: .string) else { return false }

        guard let fromItem = data.search(dragName) else { fatalError("unknown data passed") }
        let fromIndex = fromItem.indexPath()
        let toIndex: IndexPath
        if let item = item as? TreeNode<String> {
            toIndex = item.indexPath().appending(index)
        } else {
            toIndex = IndexPath(indexes: [index])
        }
        //print("fromIndex: \(fromIndex) toIndex: \(toIndex)")
        objectWillChange.send()
        data.move(from: fromIndex, to: toIndex)
        return true
    }
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        guard let dragName = info.draggingPasteboard.string(forType: .string),
              let dragItem = data.search(dragName) else { return NSDragOperation(rawValue: 0)}

        let fromIndex = dragItem.indexPath()
        let toIndex: IndexPath
        if let item = item as? TreeNode<String> {
            toIndex = item.indexPath().appending(index)
        } else {
            toIndex = IndexPath(indexes: [index])
        }

        if fromIndex == toIndex.prefix(fromIndex.count) {
            // looks parent is trying to move to its child
            return NSDragOperation(rawValue: 0)
        }
        return .move
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
