// SPDX-License-Identifier: GPL-3.0-only

import Collections

public protocol Graph<Element> {
    associatedtype Element

    associatedtype Index: Comparable, Equatable, Hashable

    subscript(index: Self.Index) -> Self.Element { get }

    func neighbors(of element: Self.Index) -> [Self.Index]
    func distance(from first: Self.Index, to second: Self.Index) -> Int

    var indices: [Self.Index] { get }
    var count: Int { get }
}

public extension Graph {
    func distancesAndPreviousIndexMap(
        for start: Self.Index
    ) -> (distances: [Self.Index: Int], previous: [Self.Index: Self.Index]) {
        var previous: [Self.Index: Self.Index] = [:]
        var distances = [start: 0]

        var visiting: PriorityQueue<Self.Index> = PriorityQueue()
        visiting.insert(start, withPriority: 0)

        while let next = visiting.popFirst() {
            guard next.priority != Int.max else { break }

            let current = next.element
            let currentDistance = distances[current, default: Int.max]

            self.neighbors(of: current)
                .forEach { neighbor in
                    let oldDistance = distances[neighbor, default: Int.max]
                    let newDistance = currentDistance + self.distance(from: current, to: neighbor)
                    if newDistance < oldDistance {
                        previous[neighbor] = current
                        distances[neighbor] = newDistance
                        visiting.insert(neighbor, withPriority: newDistance)
                    }
                }
        }

        return (distances: distances, previous: previous)
    }

    func path(from start: Self.Index, to end: Self.Index) -> some Sequence<Self.Index> {
        let (_, previous) = self.distancesAndPreviousIndexMap(for: start)

        var result: List<Self.Index> = .empty

        var current = end
        while current != start {
            result = result.prepend(current)
            guard let prev = previous[current] else { return List.empty }
            current = prev
        }

        return result.prepend(current)
    }
}
