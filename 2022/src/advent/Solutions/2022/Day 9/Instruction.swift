// SPDX-License-Identifier: GPL-3.0-only

extension Solutions.Year2022.Day9 {
    typealias Instructions = [Instruction]

    enum Instruction: String, RawRepresentable {
        case up = "U"
        case down = "D"
        case left = "L"
        case right = "R"
    }
}
