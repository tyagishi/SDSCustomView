//
//  HierarchicalPicker.swift
//
//  Created by : Tomoaki Yagishita on 2024/09/26
//  © 2024  SmallDeskSoftware
//

import SwiftUI
import SDSDataStructure

public struct HierarchicalPicker<Element: Identifiable, V: View>: View {
    let rootNodes: [TreeNode<Element>]
    @Binding var selected: TreeNode<Element>?

    let labelView: (TreeNode<Element>?) -> V
    
    public init(_ nodes: [TreeNode<Element>],
                selection: Binding<TreeNode<Element>?>,
                labelView: @escaping (TreeNode<Element>?) -> V ) {
        self.rootNodes = nodes
        self._selected = selection
        self.labelView = labelView
    }

    public var body: some View {
        Menu(content: {
            ForEach(rootNodes) { node in
                if node.children.isEmpty {
                    Button(action: { selected = node },
                           label: { labelView(node) })
                } else {
                    Menu(content: {
                        ForEach(node.children) { child in
                            Button(action: { selected = child },
                                   label: { labelView(child) })
                        }
                    }, label: {
                        // note: even using Button, intermid menu can not be clickable
                        labelView(node)
                    })
                }
            }
        }, label: { labelView(selected) })
    }
}
