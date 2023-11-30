// SPDX-License-Identifier: GPL-3.0-only

extension List: Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.cons(_, _), .empty), (.empty, .cons(_, _)):
            return false
        case (.cons(let lcar, let lcdr), (.cons(let rcar, let rcdr))):
            return lcar == rcar && lcdr == rcdr
        }
    }
}
