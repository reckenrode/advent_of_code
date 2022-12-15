// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder

import Algorithms

import AdventCommon

struct SandGrid {
    private var bitmap: Data
    private let viewport: Rect

    private var fallingSand: [Point] = []

    // MARK: - Parsing

    init?(contentsOf string: String, with shouldAddFloor: Bool = false) {
        let pair = Regex {
            let number = TryCapture(OneOrMore(.digit)) { Int($0) }
            number; ","; number
        }

        var paths: [[Point]] = string
            .split(separator: /\n/)
            .map { line in
                return line
                    .matches(of: pair)
                    .map { rawPoint in
                        let (_, x, y) = rawPoint.output
                        return Point(x: x, y: y)
                    }
            }

        let points = paths.joined()
        let xs = points.lazy.map(\.x)
        let ys = points.lazy.map(\.y)

        guard var (minX, maxX) = xs.minAndMax() else { return nil }
        guard var (minY, maxY) = ys.minAndMax() else { return nil }

        minY = min(0, minY) // Ensure the top of the area is included in the grid

        if shouldAddFloor {
            let extraWidth = 2 * (maxY - minY) - (maxX - minX)
            minX -= extraWidth
            maxX += extraWidth
            paths.append([Point(x: minX, y: maxY + 2), Point(x: maxX, y: maxY + 2)])
            maxY += 2
        }

        self.viewport = Rect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        self.bitmap = Data(repeating: ("." as Character).asciiValue!, count: self.viewport.area)

        paths.forEach { self.render(path: $0) }
    }

    private mutating func render(path: [Point]) {
        path.adjacentPairs().forEach { line in
            let (lhs, rhs) = (min(line.0, line.1), max(line.0, line.1))
            let offset: Offset
            if lhs.x == rhs.x {
                offset = Offset(x: 0, y: 1)
            } else if lhs.y == rhs.y {
                offset = Offset(x: 1, y: 0)
            } else {
                fatalError("Diagonal lines are not supported")
            }
            var point = lhs
            while point <= rhs {
                self[point] = "#"
                point += offset
            }
        }
    }

    // MARK: - Puzzle stuff

    mutating func dropSand(at point: Int) {
        let point = Point(x: point, y: 0)
        precondition(self.viewport.contains(point))

        guard self[point] == "." else { return }

        self.fallingSand.append(point)
    }

    // Returns:
    //  - false when there is still sand to process
    //  - true when the falling sand is done
    //  - nil if any sand falls off the board
    mutating func process() -> Bool? {
        let initialSandCount = self.restingSandCount

        let down = Offset(x: 0, y: 1)
        let downleft = Offset(x: -1, y: 1)
        let downright = Offset(x: 1, y: 1)
        self.fallingSand = self.fallingSand.compactMap { particle in
            switch (particle + downleft, particle + down, particle + downright) {
            case _ where particle.y >= self.viewport.bottom:
                return nil
            case (_, let pt, _) where self[pt] == ".":
                return pt
            case (let pt, _, _) where self[pt] == ".":
                return pt
            case (_, _, let pt) where self[pt] == ".":
                return pt
            default:
                self[particle] = "o"
                return nil
            }
        }

        if self.fallingSand.count == 0 {
            if initialSandCount < self.restingSandCount {
                return true
            } else {
                return nil
            }
        } else {
            return false
        }
    }

    var restingSandCount: Int {
        let o = ("o" as Character).asciiValue!
        return self.bitmap.filter({ element in element == o }).count
    }

    // MARK: - Printing

    var description: String {
        let newline = ("\n" as Character).asciiValue!
        let bufferCapacity = self.viewport.area + self.viewport.height - 1
        return String(unsafeUninitializedCapacity: bufferCapacity) { buffer in
            var (iter, index) = buffer.initialize(
                from: self.bitmap
                    .chunks(ofCount: self.viewport.width)
                    .joined(by: newline)
            )
            assert(iter.next() == nil, "the iterator should be consumed")
            return index
        }
    }

    // MARK: - Grid access

    private subscript(point: Point) -> String {
        get {
            guard self.viewport.contains(point) else { return "." }

            return String(unsafeUninitializedCapacity: 1) { buffer in
                let x = point.x - self.viewport.x
                let y = point.y - self.viewport.y
                buffer[0] = self.bitmap[x + y * self.viewport.width]
                return 1
            }
        }
        set {
            guard
                self.viewport.contains(point),
                let first = newValue.first,
                let asciiValue = first.asciiValue
            else { return }

            let x = point.x - self.viewport.x
            let y = point.y - self.viewport.y

            self.bitmap[x + y * self.viewport.width] = asciiValue
        }
    }
}
