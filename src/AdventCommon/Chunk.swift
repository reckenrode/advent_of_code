// SPDX-License-Identifier: GPL-3.0-only

extension Sequence {
    public func chunking(upTo size: Int) -> some Sequence<[Self.Element]> {
        return sequence(state: self.makeIterator()) { it in
            var result: [Self.Element] = []
            for _ in 0..<size {
                guard let value = it.next() else {
                    if result.count == 0 {
                        return nil
                    } else {
                        return result
                    }
                }
                result.append(value)
            }
            return result
        }
    }
}
