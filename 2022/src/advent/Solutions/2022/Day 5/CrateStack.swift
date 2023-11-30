// SPDX-License-Identifier: GPL-3.0-only

import Algorithms
import DequeModule

struct CrateStack {
    private var stack: [Deque<Crate>] = []

    var description: String {
        let height = self.stack.map(\.count).max(by: <) ?? 0

        let renderedCrates = (0..<height).map { row in
            (1..<self.stack.count).map { column in
                let stack = self.stack[column]
                if stack.count + row < height {
                    return "   "
                } else {
                    return stack[row - (height - stack.count)].description
                }
            }
            .joined(by: " ")
        }
        let labels = (1..<self.stack.count).map { " \($0) " }
            .joined(by: " ")

        let result = chain(renderedCrates, [labels]).joined(by: "\n")
        return String(result)
    }

    mutating func add(crates: [(stack: Int, item: Crate)]) {
        for crate in crates {
            while self.stack.count <= crate.stack {
                self.stack.append([])
            }
            self.stack[crate.stack].append(crate.item)
        }
    }

    func movingSingleCrates(following moves: [CrateMove]) -> CrateStack {
        var result = CrateStack(stack: self.stack)
        for move in moves {
            for _ in 0..<move.quantity {
                guard let crate = result.stack[move.source].popFirst() else {
                    fatalError("Invalid move tried to move a crate from an empty stack")
                }
                result.stack[move.destination].prepend(crate)
            }
        }
        return result
    }

    func movingMultipleCrates(following moves: [CrateMove]) -> CrateStack {
        var result = CrateStack(stack: self.stack)
        for move in moves {
            var claw: [Crate] = []
            for _ in 0..<move.quantity {
                guard let crate = result.stack[move.source].popFirst() else {
                    fatalError("Invalid move tried to move a crate from an empty stack")
                }
                claw.append(crate)
            }
            result.stack[move.destination].prepend(contentsOf: claw)
        }
        return result
    }

    var topCrates: [Crate] {
        return self.stack.compactMap(\.first)
    }
}
