// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import Collections

import AdventCommon

struct AreaMap {
    let width: Int
    let height: Int
    fileprivate let contents: Data

    // MARK: - Indexing

    subscript(x: Int, y: Int) -> UInt8? {
        guard x >= 0, x < self.width else { return nil }
        guard y >= 0, y < self.height else { return nil }

        return self.contents[self.width * y + x]
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

    // MARK: - Path-finding

    private func neighbors(of point: Point) -> [Point] {
        let candidates = [
            Point(x: point.x - 1, y: point.y),
            Point(x: point.x + 1, y: point.y),
            Point(x: point.x, y: point.y - 1),
            Point(x: point.x, y: point.y + 1),
        ]
        return candidates.filter { neighbor in
            guard
                let myElevation = self[point.x, point.y],
                let neighborElevation = self[neighbor.x, neighbor.y]
            else { return false }

            return neighborElevation <= 1 + myElevation
        }
    }

    struct Node: Comparable {
        let point: Point
        let distance: Int

        static func < (lhs: AreaMap.Node, rhs: AreaMap.Node) -> Bool {
            return lhs.distance < rhs.distance
            || (lhs.distance == rhs.distance && lhs.point < rhs.point)
        }
    }

    func findPath(from start: Point, to end: Point) -> [Point]? {
        var distances = Array(
            repeating: Array(repeating: Int.max, count: self.height),
            count: self.width
        )
        distances[start.x][start.y] = 0

        var visited = Array(
            repeating: Array(repeating: false, count: self.height),
            count: self.width
        )

        var prevNode = Array(
            repeating: Array(repeating: Point.origin, count: self.height),
            count: self.width
        )

        var visiting = Heap(
            (0..<self.height).flatMap { row in
                (0..<self.width).map { col in
                    return Node(
                        point: Point(x: col, y: row),
                        distance: distances[col][row]
                    )
                }
            }
        )

        while let next = visiting.popMin() {
            guard next.distance != Int.max, !visited[next.point.x][next.point.y] else { break }

            let current = next.point

            let currentDistance = distances[current.x][current.y]
            self.neighbors(of: current)
                .forEach { neighbor in
                    guard !visited[neighbor.x][neighbor.y] else { return }

                    let neighborDistance = currentDistance + current.distance(to: neighbor)
                    if neighborDistance < distances[neighbor.x][neighbor.y] {
                        prevNode[neighbor.x][neighbor.y] = current
                        distances[neighbor.x][neighbor.y] = neighborDistance
                        visiting.insert(Node(point: neighbor, distance: neighborDistance))
                    }
                }
            visited[current.x][current.y] = true
        }

        guard distances[end.x][end.y] != Int.max else { return nil }

        // Walk the distances grid to find the shortest path nodes.
        // It’s not needed for the solution, but it lets the path be pretty printed to the console.
        let result = sequence(state: (end, distances[end.x][end.y])) { state -> Point? in
            let (current, distance) = state
            guard distance >= 0 else { return nil }
            if current == start {
                state = (current, -1)
            } else {
                state = (prevNode[current.x][current.y], distances[current.x][current.y])
            }
            return current
        }
        return result.reversed()
    }
}
