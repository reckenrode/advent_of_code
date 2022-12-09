// SPDX-License-Identifier: GPL-3.0-only

extension Solutions.Year2022.Day9 {
    struct Simulation {
        private(set) var rope: [Knot]

        mutating func update(with instruction: Instruction) {
            instruction.apply(to: &self.rope[self.rope.startIndex])

            for (nextIndex, index) in self.rope.indices.adjacentPairs() {
                if self.rope[index].distance(to: self.rope[nextIndex]) > 1 {
                    self.rope[index].move(towards: self.rope[nextIndex], by: 1)
                }
            }
        }
    }
}
