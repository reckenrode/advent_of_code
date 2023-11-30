// SPDX-License-Identifier: GPL-3.0-only

import XCTest

import AdventCommon

final class ListEquatableTests: XCTestCase {
    func testEmptyListsAreEqual() {
        let lhs: List<Int> = []
        let rhs: List<Int> = .empty
        XCTAssertTrue(lhs == rhs)
    }

    func testIdenticalListsAreEqual() {
        let lhs: List<Int> = [1, 2, 3]
        let rhs: List<Int> = [1, 2, 3]
        XCTAssertTrue(lhs == rhs)
    }

    func testListsOfDifferentLengthsAreNotEqual() {
        let lhs: List<Int> = [1, 2, 3]
        let rhs: List<Int> = [1, 2, 3, 4]
        XCTAssertFalse(lhs == rhs)
    }

    func testInequalityIsSupported() {
        let lhs: List<Int> = [1, 2, 3, 4]
        let rhs: List<Int> = [1, 2, 3]
        XCTAssertTrue(lhs != rhs)
    }
}
