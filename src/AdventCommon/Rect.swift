// SPDX-License-Identifier: GPL-3.0-only

public struct Rect {
    public let position: Point
    public let size: Size

    public var x: Int { self.position.x }
    public var y: Int { self.position.y }

    public var width: Int { self.size.width }
    public var height: Int { self.size.height }

    public var area: Int { self.size.area }

    public var top: Int { self.y }
    public var bottom: Int { self.y + self.height }

    public var left: Int { self.x }
    public var right: Int { self.x + self.width }

    public init(position: Point, size: Size) {
        self.position = position
        self.size = size
    }

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.position = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }

    public func contains(_ point: Point) -> Bool {
        return point.x >= self.left && point.x < self.right
        && point.y >= self.top && point.y < self.bottom
    }
}
