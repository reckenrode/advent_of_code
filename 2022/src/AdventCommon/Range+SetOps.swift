// SPDX-License-Identifier: GPL-3.0-only

extension Range {
    public func isDisjoint(with other: Self) -> Bool {
        return self.lowerBound >= other.upperBound || self.upperBound <= other.lowerBound
    }

    public func isSuperset(of other: Self) -> Bool {
        return self.lowerBound <= other.lowerBound && self.upperBound >= other.upperBound
    }
}
