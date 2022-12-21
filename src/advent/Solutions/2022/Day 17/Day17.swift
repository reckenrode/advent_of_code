// SPDX-License-Identifier: GPL-3.0-only

import Darwin
import RegexBuilder
import System

import Algorithms
import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day17: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Pyroclastic Flow")
        
        @Argument(help: "puzzle input") var input: FilePath

        @Option(help: "how many rocks to drop") var rocks: Int = 2022

        func moves(in string: String) -> [RockField.Rock.MovementDirection] {
            return string.compactMap { .init(rawValue: String($0)) }
        }

        func run() throws {
            let data = try String(contentsOfFile: self.input.string)

            let rockHeight = count(
                rocks: self.rocks,
                of: RockField.Rock.allCases,
                blowing: moves(in: data)
            )

            print("Height of the rock tower: \(rockHeight)")
        }
        
        // MARK: - Puzzle Solution

        func count(
            rocks: Int,
            of shapes: [RockField.Rock],
            blowing moves: [RockField.Rock.MovementDirection]
        ) -> Int {
            var moveCycle = moves.cycled().makeIterator()
            var shapeCycle = shapes.cycled().makeIterator()

            var field = RockField()

            var height = 0
            var history: [Int: Int] = [:]

            var n = 0
            var iterations = rocks
            while n < iterations {
                precondition(field.fallingRock == nil)

                field.drop(rock: shapeCycle.next()!)

                var commands = [Command.push, .drop].cycled().makeIterator()
                while field.fallingRock != nil {
                    commands.next()!.execute(
                        on: &field,
                        withWind: &moveCycle
                    )
                }

                if height == 0 {
                    if let result = field.findCycle() {
                        guard let cycleStart = history[result.offset] else {
                            fatalError("Encountered a cycle start that is not in the history")
                        }

                        let cycleSize = (n - cycleStart) / 2
                        let cycles = rocks / cycleSize

                        height = result.size * (cycles - 2)
                        iterations = n + rocks - cycleStart - cycles * cycleSize
                    } else {
                        history[field.height] = min(history[field.height, default: Int.max], n)
                    }
                }
                n += 1
            }

            return height + field.height
        }

        enum Command {
            case drop, push

            func execute(
                on field: inout RockField,
                withWind direction: inout some IteratorProtocol<RockField.Rock.MovementDirection>
            ) {
                switch self {
                case .drop:
                    field.moveRock(.down)
                case .push:
                    field.moveRock(direction.next()!)
                }
            }
        }
    }
}
