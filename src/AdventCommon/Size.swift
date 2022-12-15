// SPDX-License-Identifier: GPL-3.0-only

public struct Size {
    public let width: Int
    public let height: Int

    public var area: Int { self.width * self.height }

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}
