// SPDX-License-Identifier: GPL-3.0-only

import AdventCommon

extension PacketData: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral: Self.IntegerLiteralType) {
        self = .integer(integerLiteral)
    }
}
