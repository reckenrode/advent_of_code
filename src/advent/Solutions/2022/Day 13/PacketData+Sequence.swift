// SPDX-License-Identifier: GPL-3.0-only

extension PacketData: IteratorProtocol, Sequence {
    public typealias Element = PacketData

    public typealias Iterator = PacketData

    public mutating func next() -> Self.Element? {
        switch self {
        case .integer(let x):
            self = .list(.empty)
            return .integer(x)
        case .list(.empty):
            return nil
        case .list(.cons(let car, let cdr)):
            self = .list(cdr)
            return car
        }
    }
}
