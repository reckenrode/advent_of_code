// SPDX-License-Identifier: GPL-3.0-only

struct Point: Equatable, Hashable {
    let x: Int
    let y: Int

    static let origin = Point(x: 0, y: 0)

    static func +(lhs: Point, rhs: Offset) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func +=(lhs: inout Point, rhs: Offset) {
        lhs = lhs + rhs
    }
}
