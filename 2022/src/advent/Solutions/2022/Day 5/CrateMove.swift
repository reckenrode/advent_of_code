// SPDX-License-Identifier: GPL-3.0-only

struct CrateMove {
    let quantity: Int
    let source: Int
    let destination: Int

    var description: String { "move \(quantity) from \(source) to \(destination)" }
}
