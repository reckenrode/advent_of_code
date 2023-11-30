// SPDX-License-Identifier: GPL-3.0-only

import XCTest

import AdventCommon

final class GreatestCommonDivisor: XCTestCase {
    func testSameValue() throws {
        let expectedResult = 8
        let gcd = 8.gcd(8)
        XCTAssertEqual(gcd, expectedResult)
    }

    func testFirstIsLessThanSecond() throws {
        let expectedResult = 5
        let gcd = 15.gcd(25)
        XCTAssertEqual(gcd, expectedResult)
    }

    func testSecondIsLessThanFirst() throws {
        let expectedResult = 22
        let gcd = 66.gcd(44)
        XCTAssertEqual(gcd, expectedResult)
    }

    func testNoCommonDivisor() throws {
        let expectedResult = 1
        let gcd = 98.gcd(79)
        XCTAssertEqual(gcd, expectedResult)
    }

    func testFirstIsVeryBig() throws {
        let expectedResult = 5
        let gcd = 65.gcd(4754080)
        XCTAssertEqual(gcd, expectedResult)
    }
}
