// SPDX-License-Identifier: GPL-3.0-only

import XCTest

import AdventCommon

final class LeastCommonMultiple: XCTestCase {
    func testSameValue() throws {
        let expectedResult = 8
        let gcd = 8.lcm(8)
        XCTAssertEqual(gcd, expectedResult)
    }

    func testFirstIsLessThanSecond() throws {
        let expectedResult = 75
        let gcd = 15.lcm(25)
        XCTAssertEqual(gcd, expectedResult)
    }

    func testSecondIsLessThanFirst() throws {
        let expectedResult = 132
        let gcd = 66.lcm(44)
        XCTAssertEqual(gcd, expectedResult)
    }
}
