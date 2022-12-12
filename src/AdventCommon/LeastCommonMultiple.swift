// SPDX-License-Identifier: GPL-3.0-only

extension BinaryInteger {
    public func lcm(_ other: Self) -> Self {
        let gcd = self.gcd(other)
        guard gcd != self && gcd != other else { return max(self, other) }
        return self * other / gcd
    }
}
