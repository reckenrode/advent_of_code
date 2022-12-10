// SPDX-License-Identifier: GPL-3.0-only

extension Solutions.Year2022.Day10 {
    typealias Program = [Instruction]

    enum Instruction {
        case noop, addx(v: Int)
    }
}
