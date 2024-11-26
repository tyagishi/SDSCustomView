//
//  EnvironmentValues.swift
//  SDSCustomView
//
//  Created by Tomoaki Yagishita on 2024/11/26.
//

import Foundation
import SwiftUI

// MARK: valueStyle ViewModifier
public struct EditableViewEditButtonLocationKey: EnvironmentKey {
    public typealias Value = TextAlignment
    public static let defaultValue = TextAlignment.leading
}
extension EnvironmentValues {
    public var editableViewEditButtonLocation: TextAlignment {
        get { return self[EditableViewEditButtonLocationKey.self] }
        set { self[EditableViewEditButtonLocationKey.self] = newValue }
    }
}
extension View {
    public func editButtonLocation(_ alignment: TextAlignment = .leading) -> some View {
        self.environment(\.editableViewEditButtonLocation, alignment)
    }
}

public struct EditableValueForegroundColorKey: EnvironmentKey {
    public typealias Value = Color
    public static var defaultValue: Color = Color.primary
}

extension EnvironmentValues {
    public var editableValueForgroundColorKey: Color {
        get { return self[EditableValueForegroundColorKey.self] }
        set { self[EditableValueForegroundColorKey.self] = newValue }
    }
}

// MARK: indirectEdit ViewModifier
public struct EditableValueIndirectKey: EnvironmentKey {
    public typealias Value = (Bool, Image)
    public static var defaultValue: (Bool, Image) = (false, EditableText.undoIcon)
}

extension EnvironmentValues {
    public var editableValueIndirect: (flag: Bool, image: Image) {
        get { return self[EditableValueIndirectKey.self] }
        set { self[EditableValueIndirectKey.self] = newValue }
    }
}

extension View {
    public func indirectEdit(_ flag: Bool = true, cancelImage: Image = EditableText.undoIcon) -> some View {
        self.environment(\.editableTextIndirect, (flag, cancelImage))
    }
    public func editableValueForegroundColor(_ color: Color) -> some View {
        self.environment(\.editableValueForgroundColorKey, color)
    }
}
