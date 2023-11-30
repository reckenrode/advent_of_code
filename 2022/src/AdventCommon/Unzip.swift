// SPDX-License-Identifier: GPL-3.0-only

extension Sequence {
    public func unzip<T, U>() -> (some Sequence<T>, some Sequence<U>) where Element == (T, U) {
        return (
            sequence(state: self.makeIterator(), next: { state in state.next()?.0 }),
            sequence(state: self.makeIterator(), next: { state in state.next()?.1 })
        )
    }
}
