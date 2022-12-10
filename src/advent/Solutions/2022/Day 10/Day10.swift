// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

extension Solutions.Year2022 {
    struct Day10: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Cathode-Ray Tube")

        @Argument(help: "puzzle input") var input: FilePath

        func read(file: FilePath) throws -> Program {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else {
                return []
            }
            let instructionRegex = Regex {
                let noop = TryCapture("noop", transform: { _ in Instruction.noop })
                let addx = Regex {
                    "addx "
                    TryCapture(/(-?\d+)/, transform: { val -> Instruction? in
                        guard let v = Int(val) else { return nil }
                        return Instruction.addx(v: v)
                    })
                }
                ChoiceOf { noop; addx }; Optionally("\n")
            }
            return try String(contentsOf: fileUrl)
                .matches(of: instructionRegex)
                .map {
                    guard let noop = $0.output.1 else { return $0.output.2! }
                    return noop
                }
        }

        func run() throws {
            let program = try read(file: self.input)

            var puter = Santaputer()
            puter.load(program: program)

            let interestingCycles: Set<Int> = Set([20, 60, 100, 140, 180, 220])
            let signals = sequence(state: puter) { cpu -> Int? in
                guard cpu.runOneCycle() else { return nil }
                if interestingCycles.contains(cpu.registers.cycle) {
                    return cpu.registers.cycle * cpu.registers.x
                } else {
                    return 0
                }
            }
            let signalStrength = signals.reduce(0, +)
            print("The signal strength is: \(signalStrength)")

            puter.load(program: program)

            var display = Santatube()
            display.render(host: puter)
            print(display.output)
        }
    }
}
