// SPDX-License-Identifier: GPL-3.0-only

import XCTest
@testable import advent

import AdventCommon

final class AreaMapTests: XCTestCase {
    func testFindsTrivialPath() {
        let expectedPath = (0..<26).map { Point(x: $0, y: 0) }
        let puzzle = AreaMap.load(contentsOf: "SbcdefghijklmnopqrstuvwxyE")
        let path = puzzle.map.findPath(from: puzzle.start, to: puzzle.end)
        XCTAssertEqual(path, expectedPath)
    }

    func testFindsWindingPath() {
        let expectedPath = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 2, y: 0),
            Point(x: 3, y: 0),
            Point(x: 4, y: 0),
            Point(x: 5, y: 0),
            Point(x: 6, y: 0),
            Point(x: 6, y: 1),
            Point(x: 5, y: 1),
            Point(x: 4, y: 1),
            Point(x: 3, y: 1),
            Point(x: 2, y: 1),
            Point(x: 1, y: 1),
            Point(x: 0, y: 1),
            Point(x: 0, y: 2),
            Point(x: 1, y: 2),
            Point(x: 2, y: 2),
            Point(x: 3, y: 2),
            Point(x: 4, y: 2),
            Point(x: 5, y: 2),
            Point(x: 6, y: 2),
            Point(x: 6, y: 3),
            Point(x: 5, y: 3),
            Point(x: 4, y: 3),
            Point(x: 3, y: 3),
            Point(x: 2, y: 3),
            Point(x: 1, y: 3),
            Point(x: 0, y: 3),
        ]
        let puzzle = AreaMap.load(contentsOf: "Sabcdef\nmlkjihg\nnopqrst\nEzyxwvu")
        let path = puzzle.map.findPath(from: puzzle.start, to: puzzle.end)
        XCTAssertEqual(path, expectedPath)
    }

    func testFindsDay12ExampleSolution() {
        let expectedPath = [
            Point(x: 0, y: 0),
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 1, y: 2),
            Point(x: 1, y: 3),
            Point(x: 2, y: 3),
            Point(x: 2, y: 4),
            Point(x: 3, y: 4),
            Point(x: 4, y: 4),
            Point(x: 5, y: 4),
            Point(x: 6, y: 4),
            Point(x: 7, y: 4),
            Point(x: 7, y: 3),
            Point(x: 7, y: 2),
            Point(x: 7, y: 1),
            Point(x: 7, y: 0),
            Point(x: 6, y: 0),
            Point(x: 5, y: 0),
            Point(x: 4, y: 0),
            Point(x: 3, y: 0),
            Point(x: 3, y: 1),
            Point(x: 3, y: 2),
            Point(x: 3, y: 3),
            Point(x: 4, y: 3),
            Point(x: 5, y: 3),
            Point(x: 6, y: 3),
            Point(x: 6, y: 2),
            Point(x: 6, y: 1),
            Point(x: 5, y: 1),
            Point(x: 4, y: 1),
            Point(x: 4, y: 2),
            Point(x: 5, y: 2),
        ]
        let puzzle = AreaMap.load(contentsOf: "Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi")
        let path = puzzle.map.findPath(from: puzzle.start, to: puzzle.end)
        XCTAssertEqual(path, expectedPath)
    }

    func testTakesTheShorestPath() {
        let expectedPath = [
            Point(x: 0, y: 3),
            Point(x: 1, y: 3),
            Point(x: 2, y: 3),
            Point(x: 3, y: 3),
            Point(x: 4, y: 3),
            Point(x: 5, y: 3),
            Point(x: 6, y: 3),
            Point(x: 7, y: 3),
            Point(x: 8, y: 3),
            Point(x: 9, y: 3),
            Point(x: 10, y: 3),
            Point(x: 10, y: 2),
            Point(x: 10, y: 1),
            Point(x: 11, y: 1),
            Point(x: 12, y: 1),
            Point(x: 13, y: 1),
            Point(x: 14, y: 1),
            Point(x: 15, y: 1),
            Point(x: 16, y: 1),
            Point(x: 17, y: 1),
            Point(x: 17, y: 2),
            Point(x: 17, y: 3),
            Point(x: 18, y: 3),
            Point(x: 19, y: 3),
            Point(x: 20, y: 3),
            Point(x: 20, y: 4),
            Point(x: 20, y: 5),
            Point(x: 20, y: 6),
            Point(x: 20, y: 7),
            Point(x: 21, y: 7),
            Point(x: 22, y: 7),
            Point(x: 23, y: 7),
        ]
        let puzzle = AreaMap.load(
            contentsOf:
                "abccaaaaaacccccccccccccaaaa\n" +
                "abccaaaaaacccccccccccccccca\n" +
                "abccaacaaacccccaaccccccccaa\n" +
                "Sbccccccccccccaaaccccccccaa\n" +
                "abccccccccccaaaaaaaaccccccc\n" +
                "abaaacccccccaaaaaaaaccccccc\n" +
                "abaaaccccccccaaaaaacccccccc\n" +
                "abaaaaaacccccaaaaaacccc4aaa"
        )
        let path = puzzle.map.findPath(from: puzzle.start, to: puzzle.end)
        XCTAssertEqual(path, expectedPath)
    }
}
