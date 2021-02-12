import XCTest

import RsyncTests

var tests = [XCTestCaseEntry]()
tests += RsyncTests.allTests()
XCTMain(tests)
