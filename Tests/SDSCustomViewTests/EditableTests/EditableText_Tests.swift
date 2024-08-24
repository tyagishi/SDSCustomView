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
        let sut = EditableText(value: binding).tag("EditableText")
            .editButtonLocation(.leading)
        
        let button = try sut.inspect().find(viewWithTag: "LeadingButton").button()
        XCTAssertNotNil(button)

        let text = try sut.inspect().find(viewWithTag: "EditableTextView").text()
        XCTAssertNotNil(text)
        let textString = try text.string()
        XCTAssertEqual(textString, "Test")
        
        try button.tap() // but does not work since mainthread is not running??
        
//        let field = try sut.inspect().find(viewWithTag: "EditableTextField").textField()
//        XCTAssertNotNil(field)
//        let fieldString = try field.input()
//        XCTAssertEqual(fieldString, "Test")


        // necessary child views are there
    }


}
