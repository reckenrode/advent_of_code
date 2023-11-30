// SPDX-License-Identifier: GPL-3.0-only

import AdventCommon

extension PacketData: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = PacketData

    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self = .list(List(elements))
    }
}
