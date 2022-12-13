// SPDX-License-Identifier: GPL-3.0-only

import XCTest
@testable import advent

import AdventCommon

final class KnotTests: XCTestCase {
    // MARK: - distance(to:)
    func testDistanceToTargetHorizontally() {
        let expectedDistance = 1

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 1, y: 0))
        let tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        XCTAssertEqual(tail.distance(to: head), expectedDistance)
    }

    func testDistanceToTargetVertically() {
        let expectedDistance = 5

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 0, y: 5))
        let tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        XCTAssertEqual(tail.distance(to: head), expectedDistance)
    }

    func testDistanceToTargetDiagonally() {
        let expectedDistance = 1

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 3, y: 4))
        let tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point(x: 4, y: 3))

        XCTAssertEqual(tail.distance(to: head), expectedDistance)
    }

    // MARK: - move(towards:)
    func testFollowsHorizontally() {
        let expectedPosition = Point(x: 1, y: 0)

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 2, y: 0))
        var tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        tail.move(towards: head, by: 1)

        XCTAssertEqual(tail.position, expectedPosition)
    }

    func testFollowsVertically() {
        let expectedPosition = Point(x: 0, y: 1)

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 0, y: 2))
        var tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        tail.move(towards: head, by: 1)

        XCTAssertEqual(tail.position, expectedPosition)
    }

    func testFollowsDiagonally() {
        let expectedPosition = Point(x: 1, y: 1)

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 1, y: 2))
        var tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        tail.move(towards: head, by: 1)

        XCTAssertEqual(tail.position, expectedPosition)
    }

    func testFollowsHorizontallyUpToDistanceSpecified() {
        let expectedPosition = Point(x: 4, y: 0)

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 10, y: 0))
        var tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        tail.move(towards: head, by: 4)

        XCTAssertEqual(tail.position, expectedPosition)
    }

    func testFollowsVerticallyUpToDistanceSpecified() {
        let expectedPosition = Point(x: 0, y: 50)

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 0, y: 100))
        var tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        tail.move(towards: head, by: 50)

        XCTAssertEqual(tail.position, expectedPosition)
    }

    func testFollowsDiagonallyUpToDistanceSpecified() {
        let expectedPosition = Point(x: 4, y: 4)

        let head = Solutions.Year2022.Day9.Knot(name: "H", position: Point(x: 4, y: 5))
        var tail = Solutions.Year2022.Day9.Knot(name: "T", position: Point.origin)

        tail.move(towards: head, by: 4)

        XCTAssertEqual(tail.position, expectedPosition)
    }
}
