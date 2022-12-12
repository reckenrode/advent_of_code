// SPDX-License-Identifier: GPL-3.0-only

extension BinaryInteger {
    public func gcd(_ other: Self) -> Self {
        @inline(__always)
        func loop(_ a: Self, _ b: Self, counter: Self) -> Self {
            guard a != b else { return a * counter }
            guard a != 1, b != 1 else { return 1 }

            let aResult = a.quotientAndRemainder(dividingBy: 2)
            let bResult = b.quotientAndRemainder(dividingBy: 2)

            switch (aResult.remainder == 0, bResult.remainder == 0) {
            case (true, true):
                return loop(aResult.quotient, bResult.quotient, counter: counter * 2)
            case (true, false):
                return loop(aResult.quotient, b, counter: counter)
            case (false, true):
                return loop(a, bResult.quotient, counter: counter)
            case (false, false) where a < b:
                return loop(b, a, counter: counter)
            case (false, false):
                return loop(a - b, b, counter: counter)
            }
        }
        return loop(self, other, counter: 1)
    }
}
