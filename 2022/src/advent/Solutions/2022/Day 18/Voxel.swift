// SPDX-License-Identifier: GPL-3.0-only

struct Voxel: Hashable {
    let x: Int
    let y: Int
    let z: Int

    static var origin: Voxel = Voxel(x: 0, y: 0, z: 0)
}
