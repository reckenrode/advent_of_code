// SPDX-License-Identifier: GPL-3.0-only

struct Elf {
    let inventory: [Int]
    var carriedCalories: Int {
        self.inventory.reduce(0, +)
    }
}

extension Elf {
    init?(of string: String) {
        let parseResult = try? Elf.Parser().consuming(
            string,
            startingAt: string.startIndex,
            in: string.startIndex..<string.endIndex
        )
        guard let parseResult else { return nil }

        self = parseResult.output
    }
}
