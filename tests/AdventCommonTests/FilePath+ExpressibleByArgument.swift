// SPDX-License-Identifier: GPL-3.0-only

import System
import XCTest

import AdventCommon

final class FilePathExpressibleByArgument: XCTestCase {
    func testWrapsStringInAPath() throws {
        let expectedPath = FilePath("foo")
        let path = FilePath(argument: "foo")
        XCTAssertEqual(path, expectedPath)
    }

    func testRemovesIntermediatePaths() throws {
        let expectedPath = FilePath("/some/path")
        let path = FilePath(argument: "/some/.././some/./path/there/../")
        XCTAssertEqual(path, expectedPath)
    }
}
