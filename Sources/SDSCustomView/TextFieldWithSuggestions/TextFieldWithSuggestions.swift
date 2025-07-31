//
//  TextFieldWithSuggestions.swift
//  ComplementTextField
//
//  Created by Tomoaki Yagishita on 2025/07/04.
//

import SwiftUI
import SDSMacros
import SDSViewExtension

@IsCheckEnum
@AssociatedValueEnum
public enum TextFieldWithSuggestionsViewAdjustment {
    case none
    case endOfText
    case specify(CGFloat)
}

public struct TextFieldWithSuggestionsViewAdjustmentKey: EnvironmentKey {
    public typealias Value = TextFieldWithSuggestionsViewAdjustment
    public static let defaultValue = TextFieldWithSuggestionsViewAdjustment.endOfText
}
extension EnvironmentValues {
    public var textFieldWithSuggestionsViewAdjustment: TextFieldWithSuggestionsViewAdjustment {
        get { return self[TextFieldWithSuggestionsViewAdjustmentKey.self] }
        set { self[TextFieldWithSuggestionsViewAdjustmentKey.self] = newValue }
    }
}
extension View {
    public func suggestionsViewAdjustment(_ alignment: TextFieldWithSuggestionsViewAdjustment = .endOfText) -> some View {
        self.environment(\.textFieldWithSuggestionsViewAdjustment, alignment)
    }
}

@IsCheckEnum
@AssociatedValueEnum
enum FocusElement: Hashable {
    case textField
    case complement(Int)
    
    func nextComplement(in total: Int) -> FocusElement? {
        guard let value = self.complementValues else { return nil }
        let nextValue = (value + 1) % total
        return .complement(nextValue)
    }
    func prevComplement(in total: Int) -> FocusElement? {
        guard let value = self.complementValues else { return nil }
        let prevValue = (value - 1 + total) % total
        return .complement(prevValue)
    }
}

@available(iOS 18, macOS 15, *)
public struct TextFieldWithSuggestions: View {
    @Environment(\.textFieldWithSuggestionsViewAdjustment) var viewAdjustment
    @Binding var displayText: String
    let suggestions: (String) -> [String]
    let trigger: (String) -> Bool
    let handler: (String, String) -> String

    @FocusState private var focus: FocusElement?
    @State private var selection: TextSelection?
    @State private var showComplementList = false
    @State private var complementText: String = ""
    
    @State private var currentTextWidth: CGFloat = 0
    @State private var textFieldWidth: CGFloat = 0

    public init(_ text: Binding<String>, suggestions: @escaping (String) -> [String],
                trigger: @escaping (String) -> Bool,
                handler: @escaping (String, String) -> String) {
        self._displayText = text
        self.suggestions = suggestions
        self.trigger = trigger
        self.handler = handler
    }
    
    public var body: some View {
        VStack(spacing: 0, content: {
            TextField("Input: ", text: $displayText, selection: $selection)
                .focused($focus, equals: .textField)
                .onChange(of: displayText, {
                    guard !suggestions(displayText).isEmpty else { return }
                    if trigger(displayText) {
                        focus = .complement(0)
                        showComplementList = true
                    } else {
                        showComplementList = false
                    }
                })
                .onKeyPress(.downArrow, action: {
                    guard !suggestions(displayText).isEmpty else { return .ignored }
                    focus = .complement(0)
                    showComplementList = true
                    return .handled
                })
                .readGeom(onChange: { proxy in textFieldWidth = proxy.size.width })
                .background {
                    // retrieve text width
                    Text(displayText).hidden()
                        .readGeom(onChange: { proxy in currentTextWidth = proxy.size.width })
                }
                .overlay(alignment: .leading, content: {
                    if showComplementList {
                        suggestionView
                    }
                })
        })
    }
    
    @ViewBuilder
    var suggestionView: some View {
        let suggestionItems = Array(suggestions(displayText).enumerated())
        ScrollViewReader(content: { scrollProxy in
            ScrollView(.horizontal, content: {
                HStack {
                    ForEach(suggestionItems, id: \.0, content: { (index, title) in
                        Button(action: {
                            complementText = title
                        }, label: { Text(title) }).id(title)
                        .focused($focus, equals: .complement(index))
                    })
                    Spacer()
                }
                .onKeyPress(action: { key in
                    switch keyFunction(key) {
                    case nil:      return .ignored
                    case .rightArrow:
                        guard let focus = focus else { return .ignored }
                        self.focus = focus.nextComplement(in: suggestionItems.count)
                    case .leftArrow:
                        guard let focus = focus else { return .ignored }
                        self.focus = focus.prevComplement(in: suggestionItems.count)
                    case .return:
                        guard let selection = focus?.complementValues else { return .ignored }
                        complementText = suggestionItems[selection].1
                    case .escape:
                        self.focus = .textField
                    }
                    return .handled
                })
                .onChange(of: complementText, {
                    guard !complementText.isEmpty else { return }
                    displayText = handler(displayText, complementText)
                    self.complementText = ""
                    // note: can not combine following two request into one...
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.001, execute: {
                        focus = .textField
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
                        selection = .init(insertionPoint: displayText.endIndex)
                    })
                })
                .onChange(of: focus, {
                    // note: if complement list loose focus, should disappear
                    guard let focus = focus else { return }
                    if !focus.isComplement { showComplementList = false }
                })
                .onChange(of: focus, {
                    // scroll to focused element
                    guard let focusIndex = focus?.complementValues else { return }
                    let itemID = suggestionItems[focusIndex].1
                    scrollProxy.scrollTo(itemID)
                })
            })
        })
        .background(.white.opacity(0.7))
        .frame(width: (textFieldWidth - currentTextWidth) * 0.7) // 少し短めで
        .offset(x: offsetX(currentTextWidth), y: 24) // TODO: may need to adjust 24
    }
    
    func offsetX(_ currentTextWidth: CGFloat) -> CGFloat {
        switch viewAdjustment {
        case .none:                return 0
        case .endOfText:           return currentTextWidth
        case .specify(let offset): return offset
        }
    }
    
    enum KeyFunction {
        case leftArrow, rightArrow, `return`, escape
    }
    
    func keyFunction(_ keyPress: KeyPress) -> KeyFunction? {
        switch keyPress.key {
        case .rightArrow:  return .rightArrow
        case .leftArrow:   return .leftArrow
        case .return:      return .return
        case .escape:      return .escape
        default:           break
        }
        if keyPress.modifiers == [.control] {
            if keyPress.key.character == "f" { return .rightArrow }
            if keyPress.key.character == "b" { return .leftArrow }
            if keyPress.key.character == "m" { return .return }
        }
        return nil
    }
    
    var popupMenu: some View {
        Menu {
            Button {
            } label: {
                Label("New Album", systemImage: "rectangle.stack.badge.plus")
            }
            Button {
            } label: {
                Label("New Folder", systemImage: "folder.badge.plus")
            }
            Button {
            } label: {
                Label("New Shared Album", systemImage: "rectangle.stack.badge.person.crop")
            }
        } label: {
            Label("Add New", systemImage: "plus")
        }
    }
}
