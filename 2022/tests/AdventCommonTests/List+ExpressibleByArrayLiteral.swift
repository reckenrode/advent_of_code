// SPDX-License-Identifier: GPL-3.0-only

import XCTest

import AdventCommon

final class ListExpressibleByArrayLiteralTests: XCTestCase {
    func testItAcceptsEmptyLists() {
        let expectedList: List<Int> = .empty
        let list: List<Int> = []
        XCTAssertEqual(list, expectedList)
    }

    func testItAcceptsListsWithElements() {
        let expectedList: List<Int> = .cons(1, .cons(2, .cons(3, .empty)))
        let list: List<Int> = [1, 2, 3]
        XCTAssertEqual(list, expectedList)
    }
}
