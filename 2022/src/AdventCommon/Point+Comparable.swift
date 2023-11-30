// SPDX-License-Identifier: GPL-3.0-only

extension Point: Comparable {
    public static func < (lhs: Point, rhs: Point) -> Bool {
        return (lhs.x < rhs.x && lhs.y == rhs.y) || lhs.y < rhs.y
    }
}
