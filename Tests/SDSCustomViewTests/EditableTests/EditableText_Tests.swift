//
//  EditableText_Tests.swift
//
//  Created by : Tomoaki Yagishita on 2024/08/23
//  © 2024  SmallDeskSoftware
//

import XCTest
import SwiftUI
import ViewInspector
@testable import SDSCustomView

final class EditableText_Tests: XCTestCase {

    @MainActor
    func test_init() async throws {
        let binding = Binding(wrappedValue: "Test")
        var sut = EditableText(value: binding)


        let exp = sut.on(\.didAppear) { view in
//            let button = try XCTUnwrap(sut.inspect().find(viewWithTag: "LeadingButton").button())
            let text = try XCTUnwrap(sut.inspect().find(viewWithTag: "EditableTextView").text())
//            let textString = try sut.inspect().find(viewWithAccessibilityIdentifier: "")
            XCTAssertEqual(try text.string(), "Test")
//
//            try button.tap() // but does not work since mainthread is not running??
//            let field = try sut.inspect().find(viewWithTag: "EditableTextField")
//            XCTAssertNotNil(field)
        }
        
        ViewHosting.host(view: sut)
        
        await fulfillment(of: [exp], timeout: 3)
    }
    
    @MainActor
    func test_updateFromBindingValueChange() async throws {
        let binding = Binding(wrappedValue: "Test")
        var sut = EditableText(value: binding)


        let exp = sut.on(\.didAppear) { view in
            var text = try XCTUnwrap(sut.inspect().find(viewWithTag: "EditableTextView").text())
            XCTAssertEqual(try text.string(), "Test")
            
            binding.wrappedValue = "NewValue"
            text = try XCTUnwrap(sut.inspect().find(viewWithTag: "EditableTextView").text())
            XCTAssertEqual(try text.string(), "NewValue")
        }
        
        ViewHosting.host(view: sut)
        
        await fulfillment(of: [exp], timeout: 3)
    }
    
    @MainActor
    func test_tapThenTextFieldWillAppearThenEditThenGoBack() async throws {
        let binding = Binding(wrappedValue: "Test")
        var sut = EditableText(value: binding)

        let exp = sut.on(\.didAppear) { view in
            let button = try XCTUnwrap(try view.implicitAnyView().hStack().button(0))
            var text = try XCTUnwrap(try view.implicitAnyView().hStack().text(1))
            XCTAssertEqual(try text.string(), "Test")

            try button.tap()

            let textField = try view.implicitAnyView().hStack().tupleView(1).textField(0)
            XCTAssertEqual(try textField.input(), "Test")
            
            try textField.setInput("NewValue")
            try button.tap()
            
            text = try XCTUnwrap(try view.implicitAnyView().hStack().text(1))
            XCTAssertEqual(try text.string(), "NewValue")
            XCTAssertEqual(binding.wrappedValue, "NewValue")
        }
        ViewHosting.host(view: sut)
        
        await fulfillment(of: [exp], timeout: 3)
    }
}
