//
//  HierarchicalReorderableForEach.swift
//
//  Created by : Tomoaki Yagishita on 2022/07/22
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import UniformTypeIdentifiers
import SDSDataStructure
import Carbon.HIToolbox

let dragType = [UTType.text]

public struct HierarchicalReorderableForEach<T: Equatable, Content: View>: View {
    @ObservedObject var current: TreeNode<T>
    @ObservedObject var selection: LimitedOrderedSet<TreeNode<T>>
    let childKey: ReferenceWritableKeyPath<TreeNode<T>, [TreeNode<T>]>
    @Binding var draggingItem: TreeNode<T>?
    var moveAction: ((IndexPath, IndexPath) -> Void)?
    let content: (TreeNode<T>) -> Content


    public init( current: TreeNode<T>,
                 //selection: Binding<Set<TreeNode<T>.ID>>,
                 selection: LimitedOrderedSet<TreeNode<T>>,
                 childKey: ReferenceWritableKeyPath<TreeNode<T>,[TreeNode<T>]>,
                 draggingItem: Binding<TreeNode<T>?>,
                 moveAction: ((IndexPath, IndexPath) -> Void)?,
                 @ViewBuilder content: @escaping (TreeNode<T>) -> Content ) {
        self.current = current
        self.selection = selection
        self.childKey = childKey
        self._draggingItem = draggingItem
        self.moveAction = moveAction
        self.content = content
    }
    public var body: some View {
        ForEach(current[keyPath: childKey]) { child in
            HierarchicalReorderableRow(child, selection,
                                       \.children, $draggingItem, moveAction: moveAction,
                                       content: { treeNode in
                content(treeNode)
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
    @ObservedObject var selection: LimitedOrderedSet<TreeNode<T>>
    //@Binding var selection: Set<TreeNode<T>.ID>
    let childKey: ReferenceWritableKeyPath<TreeNode<T>, [TreeNode<T>]>
    @Binding var draggingItem: TreeNode<T>?
    var moveAction: ((IndexPath, IndexPath) -> Void)?
    let content: (TreeNode<T>) -> Content

    @State private var expand = false {
        didSet {
            UserDefaults.standard.setValue(expand, forKey: node.id.uuidString)
        }
    }
    
    public init(_ node: TreeNode<T>,
                //_ selection: Binding<Set<TreeNode<T>.ID>>,
                _ selection: LimitedOrderedSet<TreeNode<T>>,
                _ childKey: ReferenceWritableKeyPath<TreeNode<T>, [TreeNode<T>]>,
                _ draggingItem: Binding<TreeNode<T>?>,
                moveAction: ((IndexPath, IndexPath) -> Void)?,
                @ViewBuilder content: @escaping (TreeNode<T>) -> Content ) {
        self.node = node
        self.selection = selection
        self.childKey = childKey
        self._draggingItem = draggingItem
        self.moveAction = moveAction
        self.content = content
        self.expand = (UserDefaults.standard.value(forKey: node.id.uuidString) as? Bool) ?? false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if !node.children.isEmpty {
                    Image(systemName: "chevron.right").rotationEffect(expand ? .degrees(90) : .degrees(0))
                        .onTapGesture {
                            expand.toggle()
                        }
                } else {
                    Image(systemName: "minus").hidden()
                }
                if moveAction == nil {
                    content(node).frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        if selection.contains(node) {
                            selection.remove(node)
                        } else {
                            selection.insert(node)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(selection.contains(node) ? Color.blue.opacity(0.2) : Color.clear)
                            .padding(-2)
                    }
                } else {
                    content(node).frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            if selection.contains(node) {
                                selection.remove(node)
                            } else {
                                selection.insert(node)
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(selection.contains(node) ? Color.blue.opacity(0.2) : Color.clear)
                                .padding(-2)
                        }
                        .onDrag {
                            self.draggingItem = node
                            return NSItemProvider(object: ((node.value as? String) ?? "NoText") as NSString)
                        }
                        .onDrop(of: dragType, delegate: DragDelegate<T>(root: node.rootNode(),
                                                                        item: node,
                                                                        draggingItem: $draggingItem,
                                                                        moveAction: moveAction))
                }
            }
            .padding(.bottom, 8)
            if expand,
               !node.children.isEmpty {
                HierarchicalReorderableForEach(current: node, selection: selection,
                                               childKey: \.children,
                                               draggingItem: $draggingItem, moveAction: {(_,_) in },
                                               content: content)
            }
        }
        .padding(.leading, CGFloat((node.indexPath().count - 1) * 8))
    }
    
    @ViewBuilder
    var row: some View {
        HStack {
            Image(systemName: "chevron.right").rotationEffect(expand ? .degrees(90) : .degrees(0))
                .onTapGesture {
                    expand.toggle()
                }
            content(node).frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    var moveRow: some View {
        HStack {
            Image(systemName: "chevron.right").rotationEffect(expand ? .degrees(90) : .degrees(0))
                .onTapGesture {
                    expand.toggle()
                }
            content(node).frame(maxWidth: .infinity, alignment: .leading)
        }
        .onDrag {
            self.draggingItem = node
            return NSItemProvider(object: ((node.value as? String) ?? "NoText") as NSString)
        }
        .onDrop(of: dragType, delegate: DragDelegate<T>(root: node.rootNode(),
                                                        item: node,
                                                        draggingItem: $draggingItem,
                                                        moveAction: moveAction))
        .padding(.bottom, 8)
    }
}

struct DragDelegate<T>: DropDelegate {
    @ObservedObject var root: TreeNode<T>
    let item: TreeNode<T>
    @Binding var draggingItem: TreeNode<T>?
    var moveAction: ((IndexPath, IndexPath) -> Void)?

    init(root: TreeNode<T>,
         item: TreeNode<T>,
         draggingItem: Binding<TreeNode<T>?>,
         moveAction: ((IndexPath, IndexPath) -> Void)? ) {
        self.root = root
        self.item = item
        self._draggingItem = draggingItem
        self.moveAction = moveAction
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem,
              item.id != draggingItem.id,
              !draggingItem.isAncestor(of: item) else { return }

        let fromNodeIndex = draggingItem.indexPath()
        var toNodeIndex = item.indexPath()
        
        //print("DropEntered from: \(fromNodeIndex) to: \(toNodeIndex)")
        
        if item.children.isEmpty {
            // drop empty node, add as child
            toNodeIndex.append(IndexPath(index: 0))
        }
        if fromNodeIndex != toNodeIndex {
            moveAction?(fromNodeIndex, toNodeIndex)
            //root.move(from: fromNodeIndex, to: toNodeIndex)
        }
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        guard let draggingItem = draggingItem,
              item.id != draggingItem.id,
              !draggingItem.isAncestor(of: item) else { return false }
        return true
    }
    func performDrop(info: DropInfo) -> Bool {
        //print("performDrop")
        guard let draggingItem = draggingItem,
              item.id != draggingItem.id,
              !draggingItem.isAncestor(of: item) else { return false }
        self.draggingItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        guard let draggingItem = draggingItem,
              item.id != draggingItem.id,
              !draggingItem.isAncestor(of: item) else { return nil }
        return DropProposal(operation: .move)
    }
    
//    func dropExited(info: DropInfo) {
//        print("dropExited")
//        guard let draggingItem = draggingItem else { return }
//    }
}


