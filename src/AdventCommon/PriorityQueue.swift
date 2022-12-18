// SPDX-License-Identifier: GPL-3.0-only

import Collections

public struct PriorityQueue<Element: Comparable> {
    private struct ElementPriority: Comparable {
        let value: Element
        let priority: Int

        static func < (lhs: Self, rhs: Self) -> Bool {
            return lhs.priority < rhs.priority
            || (lhs.priority == rhs.priority && lhs.value < rhs.value)
        }
    }

    public init() { }

    private var queue: Heap<ElementPriority> = Heap()

    public var count: Int { self.queue.count }

    public mutating func insert(_ element: Element, withPriority priority: Int) {
        self.queue.insert(ElementPriority(value: element, priority: priority))
    }

    public mutating func popFirst() -> (element: Element, priority: Int)? {
        guard let result = self.queue.popMin() else { return nil }
        return (element: result.value, priority: result.priority)
    }

    public mutating func popLast() -> (element: Element, priority: Int)? {
        guard let result = self.queue.popMax() else { return nil }
        return (element: result.value, priority: result.priority)
    }
}
