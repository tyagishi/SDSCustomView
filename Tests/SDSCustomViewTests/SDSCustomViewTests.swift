import XCTest
@testable import SDSCustomView

final class SDSCustomViewTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(SDSCustomView().text, "Hello, World!")
        XCTFail("no tests")
    }
    func test_studyString() async throws {
        
        // add typing
        let str1 = "Hello, "
        let str2 = "Hello, a"
        
        XCTAssertEqual(str2.hasPrefix(str1), true)
        let str2Result = str2.dropFirst(str1.count)
        XCTAssertEqual(str2Result, "a")
        

        // remove, then add
        let str3 = "Hello a"
        XCTAssertEqual(str3.hasPrefix(str1), false)

    }
}
