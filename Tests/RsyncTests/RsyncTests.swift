import XCTest
@testable import Rsync

final class RsyncTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Rsync().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
