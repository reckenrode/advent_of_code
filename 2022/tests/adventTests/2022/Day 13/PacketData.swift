// SPDX-License-Identifier: GPL-3.0-only

import System
import XCTest

@testable import advent

import AdventCommon

final class PacketDataParsingTests: XCTestCase {
    func testEmptyList() {
        let expected: PacketData = []
        let input = PacketData(contentsOf: "[]")
        XCTAssertEqual(input, expected)
    }

    func testOneElement() {
        let expected: PacketData = [1]
        let input = "[1]"
        XCTAssertEqual(PacketData(contentsOf: input), expected)
    }

    func testSimpleList() {
        let expected: PacketData = [1, 1, 3, 1, 1]
        let input = "[1,1,3,1,1]"
        XCTAssertEqual(PacketData(contentsOf: input), expected)
    }

    func testNestedLists() {
        let expected: PacketData = [[1], [2, 3, 4]]
        let input = "[[1],[2,3,4]]"
        XCTAssertEqual(PacketData(contentsOf: input), expected)
    }

    func testVeryNestedLists() {
        let expected: PacketData = [1, [2, [3, [4, [5, 6, 7]]]], 8, 9]
        let input = "[1,[2,[3,[4,[5,6,7]]]],8,9]"
        XCTAssertEqual(PacketData(contentsOf: input), expected)
    }
}


final class PacketDataOrderingTests: XCTestCase {
    func testBothValuesAreIntegersLowestComesFirst() {
        let first: PacketData = 1
        let second: PacketData = 2
        XCTAssertTrue(first.isOrderedCorrectly(comparedTo: second))
    }

    func testShorterListComesFirst() {
        let first: PacketData = [1, 2, 3, 4]
        let second: PacketData = [1, 2, 3, 4, 5]
        XCTAssertTrue(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair1() {
        let first: PacketData = [1, 1, 3, 1, 1]
        let second: PacketData = [1, 1, 5, 1, 1]
        XCTAssertTrue(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair2() {
        let first: PacketData = [[1], [2, 3, 4]]
        let second: PacketData = [[1], 4]
        XCTAssertTrue(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair3() {
        let first: PacketData = [9]
        let second: PacketData = [[8, 7, 6]]
        XCTAssertFalse(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair4() {
        let first: PacketData = [[4, 4], 4, 4]
        let second: PacketData = [[4, 4], 4, 4, 4]
        XCTAssertTrue(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair5() {
        let first: PacketData = [7, 7, 7, 7]
        let second: PacketData = [7, 7, 7]
        XCTAssertFalse(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair6() {
        let first: PacketData = []
        let second: PacketData = [3]
        XCTAssertTrue(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair7() {
        let first: PacketData = [[[]]]
        let second: PacketData = [[]]
        XCTAssertFalse(first.isOrderedCorrectly(comparedTo: second))
    }

    func testExamplePair8() {
        let first: PacketData = [1, [2, [3, [4, [5, 6, 7]]]], 8, 9]
        let second: PacketData = [1, [2, [3, [4, [5, 6, 0]]]], 8, 9]
        XCTAssertFalse(first.isOrderedCorrectly(comparedTo: second))
    }
}





