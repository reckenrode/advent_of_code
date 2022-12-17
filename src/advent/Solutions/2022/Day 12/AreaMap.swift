// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import Collections

import AdventCommon

struct AreaMap: Graph {
    typealias Element = UInt8
    typealias Index = Point

    let width: Int
    let height: Int
    fileprivate let contents: Data

    // MARK: - Indexing

    subscript(index: Self.Index) -> UInt8 {
        return self.contents[self.width * index.y + index.x]
    }

    // MARK: - Introspection / Printing

    var description: String {
        let newline = ("\n" as Character).asciiValue!
        return String(unsafeUninitializedCapacity: (self.width + 1) * self.height - 1) { buffer in
            var (it, index) = buffer.initialize(
                from: self.contents[...]
                    .chunks(ofCount: self.width)
                    .joined(by: newline)
            )
            assert(it.next() == nil, "source should be consumed")
            return index
        }
    }

    // MARK: - Map-loading

    static func load(
        contentsOfFile path: FilePath
    ) throws -> (map: AreaMap, start: Point, end: Point) {
        return try load(contentsOf: String(contentsOfFile: path.string))
    }

    static func load(contentsOf string: String)  -> (map: AreaMap, start: Point, end: Point) {
        let rawLines = string.split(separator: /\n/)

        guard let width = rawLines.first?.count else { fatalError("File contained no lines") }
        let height = rawLines.count

        let cell = Regex {
            let start = /(S)/
            let end = /(E)|([0-9])/
            let terrain = /[a-z]/
            ChoiceOf { start; end; terrain }
        }

        let lines = rawLines.map { $0.matches(of: cell) }
        guard lines.allSatisfy({ $0.count == width }) else { fatalError("Unsupported jagged map") }

        var start = Point.origin
        var end = Point.origin
        var data = Data(capacity: width * height)

        for (y, line) in lines.enumerated() {
            for (x, token) in line.enumerated() {
                switch token.output {
                case (_, _, _, let num??):
                    end = Point(x: x, y: y)
                    data.append(("a" as Character).asciiValue! + UInt8(num)! - 1)
                case (_, _, "E", _):
                    end = Point(x: x, y: y)
                    data.append(("z" as Character).asciiValue!)
                case (_, "S", _, _):
                    start = Point(x: x, y: y)
                    data.append(("a" as Character).asciiValue!)
                case (let ch, _, _, _):
                    guard let asciiCh = ch.first?.asciiValue else {
                        fatalError("Non-alphabetic character found in map input")
                    }
                    data.append(asciiCh)
                }
            }
        }

        return (
            map: AreaMap(width: width, height: height, contents: data),
            start: start,
            end: end
        )
    }

    // MARK: - Graph conformance

    var count: Int { self.width * self.height }

    var indices: [Point] {
        Array((0..<self.width).flatMap { x in (0..<self.height).map { y in Point(x: x, y: y) } })
    }

    // MARK: - Path-finding

    private func inBounds(_ point: Point) -> Bool {
        return point.x >= 0 && point.x < self.width && point.y >= 0 && point.y < self.height
    }

    func distance(from first: Self.Index, to second: Self.Index) -> Int {
        return first.distance(to: second)
    }

    func neighbors(of point: Point) -> [Point] {
        let candidates = [
            Point(x: point.x - 1, y: point.y),
            Point(x: point.x + 1, y: point.y),
            Point(x: point.x, y: point.y - 1),
            Point(x: point.x, y: point.y + 1),
        ]
        return candidates.filter { neighbor in
            guard self.inBounds(point), self.inBounds(neighbor) else { return false }
            return self[neighbor] <= 1 + self[point]
        }
    }

    func findPath(from start: Point, to end: Point) -> [Point] {
        return Array(self.path(from: start, to: end))
    }
}
