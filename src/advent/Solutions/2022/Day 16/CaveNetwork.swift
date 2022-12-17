// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

import AdventCommon

struct CaveNetwork: Graph {
    private var edges: [Int]
    private var storage: [Self.Index: Self.Vertex]

    // MARK: - Initializers

    init?(contentsOf string: String) {
        let regex = Regex {
            let valve = Capture(/[A-Z]{2}/)
            let flowRate = TryCapture(OneOrMore(.digit)) { Int($0) }
            let destList = Capture(/(?:[A-Z]{2}, )*[A-Z]{2}/)
            let tunnelOrTunnels = ChoiceOf {
                "; tunnels lead to valves "
                "; tunnel leads to valve "
            }
            "Valve "; valve; " has flow rate=" ; flowRate; tunnelOrTunnels; destList
            Optionally { "\n" }
        }

        let vertices = string
            .matches(of: regex)
            .map { line in
                (
                    valve: String(line.output.1),
                    flowRate: line.output.2,
                    tunnels: line.output.3.split(separator: /,\ /).map(String.init)
                )
            }

        let rawStorage = vertices.enumerated().map { ($1.valve, ($0, $1.flowRate)) }

        self.storage = Dictionary(rawStorage, uniquingKeysWith: { lhs, _ in lhs })
        self.edges = Array(repeating: Int.min, count: self.storage.count * self.storage.count)
        self.indices = rawStorage.map(\.0)

        // Set the initial edges …
        for vertex in vertices {
            let vertexData: Vertex = self[vertex.valve]
            let edges = self.edges[slice(startingAt: vertexData.edgeIndex)]
            vertex.tunnels.forEach { valve in
                let vertex: Vertex = self[valve]
                self.edges[edges.index(edges.startIndex, offsetBy: vertex.edgeIndex)] = 1
            }
        }

        // … then calculate the shortest paths from each vertex to every other vertex …
        let allDistances = self.indices.map { vertex in
            let (distances, _) = self.distancesAndPreviousIndexMap(for: vertex)
            return (vertex, distances)
        }

        // … and set the edges in the graph to reflex these other possibilities
        allDistances.forEach { pair in
            let (startIndex, distances) = pair
            let startVertex: Vertex = self[startIndex]
            distances.forEach { targetIndex, distance in
                let endVertex: Vertex = self[targetIndex]
                let row = self.edges[slice(startingAt: startVertex.edgeIndex)]
                self.edges[row.index(row.startIndex, offsetBy: endVertex.edgeIndex)] = distance
            }
        }
    }

    // MARK: - Associated Types

    private typealias Vertex = (edgeIndex: Int, flowRate: Int)
    typealias Element = Int
    typealias Index = String

    // MARK: - Indexing

    private subscript(index: Self.Index) -> Vertex {
        guard let vertex = self.storage[index] else {
            fatalError("Vertex ‘\(index)’ is not in the cave network")
        }
        return vertex
    }

    subscript(index: Self.Index) -> Self.Element {
        return self[index].flowRate
    }

    // MARK: - Querying

    var count: Int { self.storage.count }
    var indices: [Self.Index]

    func neighbors(of element: Self.Index) -> [Self.Index] {
        let vertex: Vertex = self[element]
        return self.edges[self.slice(startingAt: vertex.edgeIndex)]
            .enumerated()
            .compactMap { index, edge -> String? in
                guard edge != Int.min else { return nil }
                return self.indices[index]
            }
    }

    func distance(from first: Self.Index, to second: Self.Index) -> Int {
        return self.edges[self.offset(of: self[first].edgeIndex, to: self[second].edgeIndex)]
    }

    // MARK: - Helpers

    private func offset(of firstIndex: Int, to secondIndex: Int) -> Int {
        return firstIndex * self.storage.count + secondIndex
    }

    private func slice(startingAt edgeIndex: Int) -> Range<Int> {
        let base = edgeIndex * self.storage.count
        return base..<(base + self.storage.count)
    }
}
