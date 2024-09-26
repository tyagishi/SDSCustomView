//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2024/09/26
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import SDSDataStructure
import SDSCustomView

extension String: Identifiable {
    public var id: String { self }
}

let testData = [TreeNode<String>(value: "Root1", children: [ TreeNode<String>(value: "Child11", children: []),
                                                             TreeNode<String>(value: "Child12", children: []),
                                                             TreeNode<String>(value: "Child13", children: []),
                                                             TreeNode<String>(value: "Child14", children: []),
                                                           ]),
                TreeNode<String>(value: "Root2", children: [ TreeNode<String>(value: "Child21", children: []),
                                                           ]),
                TreeNode<String>(value: "Root3", children: [ TreeNode<String>(value: "Child31", children: []),
                                                             TreeNode<String>(value: "Child32", children: []),
                                                             TreeNode<String>(value: "Child33", children: []),
                                                             TreeNode<String>(value: "Child34", children: []),
                                                             TreeNode<String>(value: "Child35", children: []),
                                                             TreeNode<String>(value: "Child36", children: []),
                                                             TreeNode<String>(value: "Child37", children: []),
                                                             TreeNode<String>(value: "Child38", children: []),
                                                             TreeNode<String>(value: "Child39", children: []),
                                                           ]),
                TreeNode<String>(value: "Root4", children: [/* empty */]),
                TreeNode<String>(value: "Root5", children: [ TreeNode<String>(value: "Child51", children: []),
                                                             TreeNode<String>(value: "Child52", children: []),
                                                             TreeNode<String>(value: "Child53", children: []),
                                                           ])
                ]
                   
struct ContentView: View {
    @State private var selectedID: String = "Hello"
    @State private var selectedNode: TreeNode<String>? = nil
    var body: some View {
        VStack {
            HierarchicalPicker(testData, selection: $selectedNode, labelView: { node in
                return Text(node?.value ?? "No-Element")
            }).fixedSize()
            Text("selection: \(selectedNode?.value ?? "No-Selection")")
            
            Picker(selection: $selectedID, content: {
                Text("Hello").tag("Hello")
                Text("Hallo").tag("Hallo")
                Text("Konnichiwa").tag("Konnichiwa")
                Menu(content: {
                    Text("Hello").tag("Hello1")
                    Text("Hallo").tag("Hallo1")
                    Text("Konnichiwa").tag("Konnichiwa1")
                }, label: { Text("Menu") })
            }, label: { Text("Picker") })

            Menu(content: {
                Button(action: { selectedID = "Hello"}, label: { Text("Hello") })
                Button(action: { selectedID = "Hallo"}, label: { Text("Hallo") })
                Text("Hello").tag("Hello1")
                Text("Hallo").tag("Hallo1")
                Text("Konnichiwa").tag("Konnichiwa1")
                Menu(content: {
                    Button(action: { selectedID = "Hello"}, label: { Text("Hello") })
                    Button(action: { selectedID = "Hallo"}, label: { Text("Hallo") })
                    Text("Hello").tag("Hello1")
                    Text("Hallo").tag("Hallo1")
                    Text("Konnichiwa").tag("Konnichiwa1")
                }, label: { Button(action: { selectedID = "Hello"}, label: { Text("Hello") }) })
            }, label: { Text("Menu") })

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


