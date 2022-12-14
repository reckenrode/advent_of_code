// SPDX-License-Identifier: GPL-3.0-only

extension List: IteratorProtocol, Sequence {
    public mutating func next() -> Self.Element? {
        switch self {
        case .empty:
            return nil
        case .cons(let car, let cdr):
            self = cdr
            return car
        }
    }
}
