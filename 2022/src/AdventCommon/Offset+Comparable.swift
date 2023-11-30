// SPDX-License-Identifier: GPL-3.0-only

extension Offset: Comparable {
    public static func < (lhs: Offset, rhs: Offset) -> Bool {
        return (lhs.x < rhs.x && lhs.y == rhs.y) || lhs.y < lhs.y
    }
}
