// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

import Algorithms
import Collections

struct VoxelGrid {
    private var voxels: Set<Voxel> = []
    private var internalVoxels: Set<Voxel> = []

    // MARK: - Initializers

    init(contentsOf input: String) {
        let regex = Regex {
            let digit = TryCapture(OneOrMore(.digit)) { Int($0) }
            digit; ","; digit; ","; digit
        }

        input.split(separator: /\n/)
            .forEach { line in
                guard let rawVoxel = line.firstMatch(of: regex)?.output else {
                    fatalError("Could not parse voxel definition")
                }
                self.voxels.insert(Voxel(x: rawVoxel.1, y: rawVoxel.2, z: rawVoxel.3))
            }

        self.internalVoxels = self.findInternal(
            x: self.voxels.map(\.x).minAndMax()!,
            y: self.voxels.map(\.y).minAndMax()!,
            z: self.voxels.map(\.z).minAndMax()!
        )
    }

    // MARK: - Properties

    var surfaceArea: Int {
        return self.voxels.reduce(0) { tally, voxel in
            tally + (6 - self.neighbors(of: voxel).count)
        }
    }

    var externalSurfaceArea: Int {
        let allVoxels = self.voxels.union(self.internalVoxels)
        return self.voxels.reduce(0) { tally, voxel in
            tally + (6 - self.neighbors(of: voxel, in: allVoxels).count)
        }
    }

    // MARK: - Queries

    func adjacentSpaces(of voxel: Voxel) -> [Voxel] {
        return [
            Voxel(x: voxel.x - 1, y: voxel.y, z: voxel.z),
            Voxel(x: voxel.x + 1, y: voxel.y, z: voxel.z),
            Voxel(x: voxel.x, y: voxel.y - 1, z: voxel.z),
            Voxel(x: voxel.x, y: voxel.y + 1, z: voxel.z),
            Voxel(x: voxel.x, y: voxel.y, z: voxel.z - 1),
            Voxel(x: voxel.x, y: voxel.y, z: voxel.z + 1),
        ]
    }

    func neighbors(of voxel: Voxel, in voxels: Set<Voxel>) -> [Voxel] {
        return self.adjacentSpaces(of: voxel).filter(voxels.contains)
    }

    func neighbors(of voxel: Voxel) -> [Voxel] {
        return self.neighbors(of: voxel, in: self.voxels)
    }

    // MARK: - Helpers

    private func findInternal(
        x: (min: Int, max: Int),
        y: (min: Int, max: Int),
        z: (min: Int, max: Int)
    ) -> Set<Voxel> {
        let voxels: some Sequence<Voxel> =
            sequence(state: (x: x.min, y: y.min, z: z.min)) { state in
                let result = Voxel(x: state.x, y: state.y, z: state.z)

                state.x += 1
                if state.x > x.max { state.x = x.min; state.y += 1 }
                if state.y > y.max { state.y = y.min; state.z += 1 }
                guard state.z <= z.max else { return nil }

                return result
            }
            .filter { !self.voxels.contains($0) }

        var voxelSet = Set(voxels)

        func onBoundry(_ voxel: Voxel) -> Bool {
           return voxel.x == x.min || voxel.x == x.max
           || voxel.y == y.min || voxel.y == y.max
           || voxel.z == z.min || voxel.z == z.max
        }

        while let startingPoint = voxelSet.first(where: onBoundry) {
            let external = self.connected(from: startingPoint, following: voxelSet)
            voxelSet = voxelSet.symmetricDifference(external)
        }

        return voxelSet
    }

    private func connected(
        from voxel: Voxel,
        following voxels: Set<Voxel>,
        visited: TreeSet<Voxel> = []
    ) -> TreeSet<Voxel> {
        var visited = visited
        visited.insert(voxel)

        let neighbors = self.neighbors(of: voxel, in: voxels).filter { !visited.contains($0) }
        return neighbors.reduce(visited) { visited, neighbor in
            return self.connected(from: neighbor, following: voxels, visited: visited)
        }
    }
}
