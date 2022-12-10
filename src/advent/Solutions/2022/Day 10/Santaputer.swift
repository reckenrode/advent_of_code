// SPDX-License-Identifier: GPL-3.0-only

import Collections

extension Solutions.Year2022.Day10 {
    struct Santaputer {
        struct RegisterFile {
            var x: Int = 1
            var ip: Int = 0
            var cycle: Int = 0
        }

        private(set) var registers = RegisterFile()
        private(set) var program: Program = []
        private(set) var pipeline: Deque<(inout RegisterFile) -> Void> = Deque()

        init() { }

        // Loads the program and resets the computer
        mutating func load(program: Program) {
            self.registers = RegisterFile()
            self.program = program
            self.pipeline = []
        }

        // Return value of `false` means the santaputer has nothing to execute
        mutating func runOneCycle() -> Bool {
            if let op = self.pipeline.popFirst() { op(&self.registers) }

            self.registers.cycle += 1

            if self.registers.ip < self.program.count {
                let instruction = self.program[self.registers.ip]
                self.registers.ip += 1
                switch instruction {
                case .noop:
                    self.pipeline.append { _ in return }
                case .addx(let v):
                    self.pipeline.append { _ in return }
                    self.pipeline.append { $0.x += v }
                }
            }

            return self.registers.ip < self.program.count || !self.pipeline.isEmpty
        }
    }
}
