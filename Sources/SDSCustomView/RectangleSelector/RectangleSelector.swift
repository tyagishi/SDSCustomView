//
//  ExpandableRectSelector.swift
//  ExpandableFrameExample
//
//  Created by Tomoaki Yagishita on 2025/01/27.
//

import Foundation
import SwiftUI
import SDSCGExtension
import SDSViewExtension

public enum SelectionStatus: CustomStringConvertible {
    case selection
    case resize
    case done
    public mutating func next() {
        switch self {
        case .selection: self = .resize
        case .resize:    self = .done
        case .done:      break
        }
    }
    
    public var description: String {
        switch self {
        case .selection: "selection"
        case .resize:    "resize"
        case .done:      "done"
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct RectangleSelector: View {
    @Binding var selectionState: SelectionStatus
    @Binding var rect: CGRect // origin: upper-left

    @State private var workingRect: CGRect = .zero
    
    // for selection
    @State private var startLoc: CGPoint = .zero
    @State private var dragLoc: CGPoint = .zero
    @State private var startRect: CGRect = .zero // to store initial rect for drag operation
    
    public init(state: Binding<SelectionStatus>, rect: Binding<CGRect>) {
        self._selectionState = state
        self._rect = rect
    }
    
    public var body: some View {
        ZStack {
            if selectionState != .done {
                buttons.zIndex(1)
                    .modify { view in
                        if workingRect.size == .zero {
                            view.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        } else {
                            view .position(workingRect.rectCenter())
                        }
                    }
            }
            if selectionState == .selection {
                selectView.zIndex(0.5)
            } else if selectionState == .resize,
                      workingRect.size != .zero {
                resizeView.zIndex(0.5)
            }
        }
        .onChange(of: rect, initial: true, {
            workingRect = rect
        })
    }
    
    @ViewBuilder
    var buttons: some View {
        VStack(content: {
            if workingRect != .zero {
                Button(action: {
                    selectionState = .done
                    rect = workingRect
                    workingRect = .zero
                }, label: { Text("Cancel").opacity(0.001).overlay { Text("OK") } })
                if self.selectionState != .resize {
                    Button(action: { selectionState = .resize }, label: { Text("Cancel").opacity(0.001).overlay { Text("Adjust") } })
                }
            }
            Button(action: { selectionState = .done; rect = .zero; workingRect = .zero }, label: { Text("Cancel") }).zIndex(1)
        })
    }

    @ViewBuilder
    var selectView: some View {
        Group {
            Color.white.opacity(0.000001)//.opacity(selectionState == .selection ? 0.0000001 : 0.0)
                .gesture( DragGesture()
                    .onChanged({ value in
                        guard startLoc != .zero else { startLoc = value.startLocation; workingRect.size = .zero; return }
                        dragLoc = value.location
                    })
                        .onEnded({ _ in
                            let finalRect = CGRect(point1: startLoc, point2: dragLoc)
                            workingRect = finalRect
                            startLoc = .zero
                            dragLoc = .zero
                        }))
                .overlay {
                    if startLoc != .zero,
                       dragLoc != .zero {
                        let rect = CGRect(point1: startLoc, point2: dragLoc)
                        RectShape(rect: rect).stroke(lineWidth: 3).foregroundStyle(.red)
                    }
                }
                .opacity(selectionState == .selection ? 1.0 : 0.0)
                .zIndex(0.5)
            if workingRect.size != .zero {
                RectShape(rect: workingRect).stroke(lineWidth: 3).foregroundStyle(.green)
                    .opacity(selectionState == .selection ? 1.0 : 0.0)
                    .zIndex(0.2)
            }

        }
    }

    @ViewBuilder
    var resizeView: some View {
        ZStack {
            ForEach(RectangleEdge.all8, id: \.self) { edge in
                GrabEdge(rect: $workingRect, edge: edge)
            }
            RectShape(rect: workingRect)
                .stroke(lineWidth: 2)
                .foregroundStyle(.green).zIndex(-0.5)
        }
    }
}

struct GrabEdge: View {
    @Binding var rect: CGRect
    let edge: RectangleEdge
    
    @State private var underDrag = false

    @State private var startRect: CGRect = .zero

    var body: some View {
        EdgeGrip(rect: rect, edge: edge, flipped: true)
            .stroke(lineWidth: 10)
            .foregroundStyle(underDrag ? .red : .blue)
            .gesture( DragGesture()
                .onChanged({ value in
                    if underDrag == false { startRect = rect }
                    let diffVec = CGVector(from: value.startLocation, to: value.location)
                    if let newRect = startRect.changeSizeWithMovingEdge(edge: edge, diffVec) {
                        rect = newRect
                    }
                    underDrag = true
                })
                    .onEnded({ _ in underDrag = false })
            )
    }
}

struct EdgeGrip: Shape {
    let grabRect: CGRect
    let border: RectangleEdge
    let flipped: Bool
    
    init(rect: CGRect, edge: RectangleEdge, flipped: Bool) {
        self.grabRect = rect
        self.border = edge
        self.flipped = flipped
    }

    func path(in rect: CGRect) -> Path {
        let length = min(grabRect.width, grabRect.height) / 8

        switch border {
        case .upper:
            var path = Path()
            let start = grabRect.upperMid().move(-1 * length, 0)
            path.move(to: start)
            let end = start.move(length*2, 0)
            path.addLine(to: end)
            return path
        case .lower:
            var path = Path()
            let start = grabRect.lowerMid().move(-1 * length, 0)
            path.move(to: start)
            let end = start.move(length*2, 0)
            path.addLine(to: end)
            return path
        case .right:
            var path = Path()
            let start = grabRect.rightMid().move(0, -1 * length)
            path.move(to: start)
            let end = start.move(0, length*2)
            path.addLine(to: end)
            return path
        case .left:
            var path = Path()
            let start = grabRect.leftMid().move(0, -1 * length)
            path.move(to: start)
            let end = start.move(0, length*2)
            path.addLine(to: end)
            return path
            
        case .upperLeft:
            var path = Path()
            let corner = grabRect.upperLeft()
            path.move(to: corner.move(0, length))
            path.addLine(to: corner)
            path.addLine(to: corner.move(length, 0))
            return path

        case .upperRight:
            var path = Path()
            let corner = grabRect.upperRight()
            path.move(to: corner.move(0, length))
            path.addLine(to: corner)
            path.addLine(to: corner.move(-1 * length, 0))
            return path

        case .lowerLeft:
            var path = Path()
            let corner = grabRect.lowerLeft()
            path.move(to: corner.move(0, -1 * length))
            path.addLine(to: corner)
            path.addLine(to: corner.move(length, 0))
            return path

        case .lowerRight:
            var path = Path()
            let corner = grabRect.lowerRight()
            path.move(to: corner.move(0, -1 * length))
            path.addLine(to: corner)
            path.addLine(to: corner.move(-1 * length, 0))
            return path
        }
    }
}
