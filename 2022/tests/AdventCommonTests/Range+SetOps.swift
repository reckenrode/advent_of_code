// SPDX-License-Identifier: GPL-3.0-only

import System
import XCTest

import AdventCommon

final class RangeIsSuperset: XCTestCase {
    func testIsFalseWhenNoOverlap() throws {
        let result = (0..<5).isSuperset(of: 6..<8)
        XCTAssertFalse(result)
    }

    func testIsFalseWhenPartialOverlap() throws {
        let result = (0..<5).isSuperset(of: 2..<8)
        XCTAssertFalse(result)
    }

    func testIsTrueWhenFullOverlap() throws {
        let result = (0..<5).isSuperset(of: 2..<4)
        XCTAssertTrue(result)
    }

    func testIsTrueWhenLowerEndPointOverlaps() throws {
        let result = (0..<5).isSuperset(of: 0..<4)
        XCTAssertTrue(result)
    }

    func testIsTrueWhenUpperEndPointOverlaps() throws {
        let result = (0..<5).isSuperset(of: 4..<5)
        XCTAssertTrue(result)
    }

    func testIsFalseWhenUpperEndPointOverlapsLower() throws {
        let result = (0..<5).isSuperset(of: 4..<10)
        XCTAssertFalse(result)
    }

    func testIsFalseWhenLowerEndPointOverlapsUpper() throws {
        let result = (3..<5).isSuperset(of: 0..<4)
        XCTAssertFalse(result)
    }
}

final class RangeIsDisjoint: XCTestCase {
    func testIsTrueWhenNoOverlap() throws {
        let result = (0..<5).isDisjoint(with: 6..<8)
        XCTAssertTrue(result)
    }

    func testIsFalseWhenPartialOverlap() throws {
        let result = (0..<5).isDisjoint(with: 2..<8)
        XCTAssertFalse(result)
    }

    func testIsFalseWhenFullOverlap() throws {
        let result = (0..<5).isDisjoint(with: 2..<4)
        XCTAssertFalse(result)
    }

    func testIsFalseWhenLowerEndPointOverlaps() throws {
        let result = (0..<5).isDisjoint(with: 0..<4)
        XCTAssertFalse(result)
    }

    func testIsFalseWhenUpperEndPointOverlaps() throws {
        let result = (0..<5).isDisjoint(with: 4..<5)
        XCTAssertFalse(result)
    }

    func testIsTrueWhenUpperEndPointEqualsLower() throws {
        let result = (0..<5).isDisjoint(with: 5..<10)
        XCTAssertTrue(result)
    }

    func testIsTrueWhenLowerEndPointEqualsUpper() throws {
        let result = (3..<5).isDisjoint(with: 0..<3)
        XCTAssertTrue(result)
    }
}
