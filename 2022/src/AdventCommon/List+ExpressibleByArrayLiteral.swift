// SPDX-License-Identifier: GPL-3.0-only

extension List: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element

    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self = List(elements)
    }
}
