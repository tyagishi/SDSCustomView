# SDSCustomView

convenience view collection
every view is already used for app but basically all views are under develop for improvement.

- ChartView (pure SwiftUI)

   polyline graph
   
- FixedWidthLabel (pure SwiftUI)

   Fixed width Text with using template string
   
- TableView (based on AppKit)

   wrapped NSTableView in NSScrollView
   
- OutlineView (based on AppKit)

  wrapped NSOutlineView in NSScrollView   
  
- HierarchicalReorderableForEach (OutlineView with Drag&Drop support, pure SwiftUI)

  experimental imple.

## TableView
currently only for macOS

## FixedWidthLabel

Sometimes we want to have fixed-width label"s" those have same width.
Usually we don't mind width value itself, but want to align leading/center/traiing in same width.

looks like following.

<img width=30% alt="FixedWidthLabel" src="https://user-images.githubusercontent.com/6419800/164699567-ec2592c4-3191-4b7e-8f4e-b137b62dd488.png">

You can easily achieve above layout with
```
VStack {
  FixedWidthLabel("123",widthFor: "0000").alignment(.trailing)
  FixedWidthLabel(  "1",widthFor: "0000").alignment(.trailing)
}
```

basically above is equivalent with following.
```
VStack {
    Text("0000")
      .hidden()
      .overlay(
         Text("123")
         .frame(maxWidth: .infinity, alignment: .trainling)
      )
    Text("0000")
      .hidden()
      .overlay(
         Text("1")
         .frame(maxWidth: .infinity, alignment: .trainling)
      )
}
```

Just for reducing boilerplates.

Note: it is NOT ultimately fixed width label.
in case user modify their text size setting, label width would be affected.


## FixedWidthLabel

Sometimes we want to have fixed-width label"s" those have same width.
Usually we don't mind width value itself, but want to align leading/center/traiing in same width.


## HierarchicalReorderableForEach
```
func stringExample() -> TreeNode<String> {
    let rootNode = TreeNode(value: "Root", children: [
        TreeNode(value: "Child1", children: []),
        TreeNode(value: "Child2", children: [
            TreeNode(value: "GrandChild21", children: []),
            TreeNode(value: "GrandChild22", children: []),
            TreeNode(value: "GrandChild23", children: []),
        ]),
        TreeNode(value: "Child3", children: []),
        TreeNode(value: "Child4", children: []),
        TreeNode(value: "Child5", children: []),
    ])
    return rootNode
}


struct ContentView: View {
    @StateObject private var rootNode = stringExample()
    @State private var draggingItem: TreeNode<String>? = nil

    var body: some View {
        VStack {
            HStack {
                Text("Item in tree : \(rootNode.count)")
                Button(action: {
                    print(rootNode)
                }, label: {Text("Print")})
                Button(action: {
                    rootNode.objectWillChange.send()
                }, label: {Text("Refresh")})
            }
            List {
                HierarchicalReorderableForEach(current: rootNode,
                                               childKey: \.children,
                                               draggingItem: $draggingItem,
                                               moveAction: {(from,to) in
                    rootNode.move(from: from, to: to)
                }, content: { treeNode in
                    Text(treeNode.value)
                })
            }
        }
    }
}
```
