// SPDX-License-Identifier: GPL-3.0-only

extension List: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .cons(let car, let cdr):
            hasher.combine(car)
            cdr.hash(into: &hasher)
        case .empty:
            return
        }
    }
}
