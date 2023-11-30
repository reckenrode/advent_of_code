// SPDX-License-Identifier: GPL-3.0-only

public struct Point: Equatable, Hashable {
    public let x: Int
    public let y: Int

    public static let origin = Point(x: 0, y: 0)

    // MARK: - Initializers

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    // MARK: - Point relationships

    public func distance(to other: Point) -> Int {
        guard self.x != other.x else { return abs(self.y - other.y) }
        guard self.y != other.y else { return abs(self.x - other.x) }

        let xDelta = self.x - other.x
        let yDelta = self.y - other.y

        return Int(Float64(xDelta * xDelta + yDelta * yDelta).squareRoot())
    }

    public func taxicabDistance(to other: Point) -> Int {
        return abs(self.x - other.x) + abs(self.y - other.y)
    }

    // MARK: - Operators

    public static func +(lhs: Point, rhs: Offset) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func +=(lhs: inout Point, rhs: Offset) {
        lhs = lhs + rhs
    }
}
