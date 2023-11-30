// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day9: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Rope Bridge")

        @Argument(help: "puzzle input") var input: FilePath

        func read(file: FilePath) throws -> Instructions {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else {
                return []
            }
            let instructionRegex = Regex {
                TryCapture(/[UDLR]/, transform: { Instruction(rawValue: String($0)) })
                " "
                TryCapture(OneOrMore(.digit), transform: { Int($0) })
                Optionally("\n")
            }
            return try String(contentsOf: fileUrl)
                .matches(of: instructionRegex)
                .flatMap { match in
                    let (_, instruction, distance) = match.output
                    return Array(repeating: instruction, count: distance)
                }
        }

        func run(simulation: Simulation, following instructions: Instructions) -> Set<Point> {
            var simulation = simulation
            return instructions.reduce(into: Set()) { positions, instruction in
                simulation.update(with: instruction)
                guard let tail = simulation.rope.last else { return }
                positions.insert(tail.position)
            }
        }

        func run() throws {
            let instructions = try read(file: self.input)

            let part1Rope = [Knot("H"), Knot("T")]
            let part1Sim = Simulation(rope: part1Rope)
            let part1Positions = run(simulation: part1Sim, following: instructions)
            print("Number positions visited at least once (by the tail): \(part1Positions.count)")

            let part2Knots = [
                Knot("H"),
                Knot("T1"),
                Knot("T2"),
                Knot("T3"),
                Knot("T4"),
                Knot("T5"),
                Knot("T6"),
                Knot("T7"),
                Knot("T8"),
                Knot("T9"),
            ]
            let part2Rope = Simulation(rope: part2Knots)
            let part2Positions = run(simulation: part2Rope, following: instructions)
            print("Number positions visited at least once (by the tail): \(part2Positions.count)")
        }
    }
}
