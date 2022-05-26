//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/25
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import SDSCustomView

struct Element {
    var name: String
}
class DataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate, ObservableObject {
    @Published var data = [Element(name: "item1"),
                           Element(name: "item2"),
                           Element(name: "item3"),
                           Element(name: "item4"),
                           Element(name: "item5"),
                           Element(name: "item6")]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier.init("Index") { return row }
        return data[row].name
    }
    
    // MARK: D&D -- drag
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        pbItem.setString(data[row].name, forType: .string)
        return pbItem
    }
    // MARK: D&D -- drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard let dragName = info.draggingPasteboard.string(forType: .string) else { return false }
        guard let fromIndex = data.firstIndex(where: {$0.name == dragName}) else { return false }

        let newIndex = dropOperation == .on ? row+1 : row

        move(from: fromIndex, to: newIndex)
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return .move
    }

    func move(from: Int, to: Int) {
        let indexSet = IndexSet(integer: from)
        data.move(fromOffsets: indexSet, toOffset: to)
    }
}
struct ContentView: View {
    @StateObject var dataSource = DataSource()
    var body: some View {
        VStack {
            TableView(dataSource, tableViewSetup: { tableView in
                tableView.usesAlternatingRowBackgroundColors = true

                // FIXME: how to setup columns from outside?
                let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Index"))
                column1.title = "Index"
                column1.width = 120
                tableView.addTableColumn(column1)

                let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Name"))
                column2.title = "Name"
                column2.width = 650
                tableView.addTableColumn(column2)

                // MARK: D&D
                //tableView.allowsMultipleSelection = true // plan in future
                tableView.registerForDraggedTypes([.string])
            }, scrollViewSetup: { scrollView in
                scrollView.hasVerticalScroller = true
                scrollView.hasHorizontalScroller = true
            })
        }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
