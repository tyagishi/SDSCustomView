//
//  HierarchicalReorderableForEach.swift
//
//  Created by : Tomoaki Yagishita on 2022/07/22
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import UniformTypeIdentifiers
import SDSDataStructure

let dragType = [UTType.text]

public struct HierarchicalReorderableForEach<T: Equatable, Content: View>: View {
    @ObservedObject var current: TreeNode<T>
    let childKey: ReferenceWritableKeyPath<TreeNode<T>, [TreeNode<T>]>
    @Binding var draggingItem: TreeNode<T>?
    var moveAction: (IndexPath, IndexPath) -> Void
    let content: (TreeNode<T>) -> Content

    public init( current: TreeNode<T>,
                 childKey: ReferenceWritableKeyPath<TreeNode<T>,[TreeNode<T>]>,
                 draggingItem: Binding<TreeNode<T>?>,
                 moveAction: @escaping (IndexPath, IndexPath) -> Void,
                 @ViewBuilder content: @escaping (TreeNode<T>) -> Content ) {
        self.current = current
        self.childKey = childKey
        self._draggingItem = draggingItem
        self.moveAction = moveAction
        self.content = content
    }
    public var body: some View {
        ForEach(current[keyPath: childKey]) { child in
            HierarchicalReorderableRow(child, \.children, $draggingItem, moveAction: moveAction,
                                       content: { treeNode in
                Text(treeNode.value as? String ?? "NoText")
            })
        }
        // FIXME: onInsert does not work well for ForEach which is embedded in another ForEach....
//        .onInsert(of: dragType) { index, providers in
//            guard let draggingItem = draggingItem else { return }
//            let currentIndex = current.indexPath()
//            let fromIndex = draggingItem.indexPath()
//            print("onInsert node: \(fromIndex) to: \(index) under: \(currentIndex)")
//            moveAction(fromIndex, fromIndex)
//        }
    }
}

struct HierarchicalReorderableRow<T: Equatable, Content: View>: View {
    @ObservedObject var node: TreeNode<T>
    let childKey: ReferenceWritableKeyPath<TreeNode<T>, [TreeNode<T>]>
    @Binding var draggingItem: TreeNode<T>?
    var moveAction: (IndexPath, IndexPath) -> Void
    let content: (TreeNode<T>) -> Content

    @State private var expand = false
    
    public init(_ node: TreeNode<T>,
                _ childKey: ReferenceWritableKeyPath<TreeNode<T>, [TreeNode<T>]>,
                _ draggingItem: Binding<TreeNode<T>?>,
                moveAction: @escaping (IndexPath, IndexPath) -> Void,
                @ViewBuilder content: @escaping (TreeNode<T>) -> Content ) {
        self.node = node
        self.childKey = childKey
        self._draggingItem = draggingItem
        self.moveAction = moveAction
        self.content = content
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.right").rotationEffect(expand ? .degrees(90) : .degrees(0))
                    .onTapGesture {
                        expand.toggle()
                    }
                content(node).frame(maxWidth: .infinity, alignment: .leading)
//                    .overlay(draggingItem?.id == node.id ? Color.white.opacity(0.8) : Color.clear)
            }
//            .contentShape(Rectangle())
            .onDrag {
                self.draggingItem = node
                return NSItemProvider(object: ((node.value as? String) ?? "NoText") as NSString)
            }
            .onDrop(of: dragType, delegate: DragDelegate<T>(root: node.rootNode(),
                                                            item: node,
                                                            draggingItem: $draggingItem,
                                                            moveAction: moveAction))
            .padding(.bottom, 8)
            if expand,
               !node.children.isEmpty {
                HierarchicalReorderableForEach(current: node, childKey: \.children,
                                               draggingItem: $draggingItem, moveAction: {(_,_) in },
                                               content: content)
            }
        }
        .padding(.leading, CGFloat((node.indexPath().count - 1) * 8))
    }
}

struct DragDelegate<T>: DropDelegate {
    @ObservedObject var root: TreeNode<T>
    let item: TreeNode<T>
    @Binding var draggingItem: TreeNode<T>?
    var moveAction: (IndexPath, IndexPath) -> Void

    init(root: TreeNode<T>,
         item: TreeNode<T>,
         draggingItem: Binding<TreeNode<T>?>,
         moveAction: @escaping (IndexPath, IndexPath) -> Void ) {
        self.root = root
        self.item = item
        self._draggingItem = draggingItem
        self.moveAction = moveAction
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }
        guard draggingItem.id != item.id else { return }
        //print("dropEntered")

        if draggingItem.isAncestor(of: item) { return }
        
        let fromNodeIndex = draggingItem.indexPath()
        var toNodeIndex = item.indexPath()
        
        //print("DropEntered from: \(fromNodeIndex) to: \(toNodeIndex)")
        
        if item.children.isEmpty {
            // drop empty node, add as child
            toNodeIndex.append(IndexPath(index: 0))
        }
        if fromNodeIndex != toNodeIndex {
            moveAction(fromNodeIndex, toNodeIndex)
            //root.move(from: fromNodeIndex, to: toNodeIndex)
        }
    }
    
//    func validateDrop(info: DropInfo) -> Bool {
//        guard let draggingItem = draggingItem else { return false }
//        //guard draggingItem.id != item.id else { return false }
//        return true
//    }
    func performDrop(info: DropInfo) -> Bool {
        //print("performDrop")
        guard let _ = draggingItem else { return false }
//        if item.id == draggingItem.id {
        self.draggingItem = nil
//        }
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
//        print("dropUpdated at \(item.value)")
        guard let draggingItem = draggingItem else { return nil }
        if item.id == draggingItem.id { return nil }
        if draggingItem.isAncestor(of: item) { return nil }
        return DropProposal(operation: .move)
    }
    
//    func dropExited(info: DropInfo) {
//        print("dropExited")
//        guard let draggingItem = draggingItem else { return }
//    }
}
