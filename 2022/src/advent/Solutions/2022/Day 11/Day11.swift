// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

extension Solutions.Year2022 {
    struct Day11: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Monkey in the Middle")

        @Argument(help: "puzzle input") var input: FilePath

        @Option(help: "worry divisor") var worryReduction: Int = 3
        @Option(help: "cycles") var cycles: Int = 20

        func read(file: FilePath) throws -> (Santa, [Monkey]) {
            let santa = Santa(worryReduction: self.worryReduction)
            let monkeys = try Monkey.load(from: file, itemsOwnedBy: santa)
            return (santa, monkeys)
        }

        func run() throws {
            let (santa, monkeys) = try read(file: self.input)
            withExtendedLifetime(santa) {
                var totals = Array(repeating: 0, count: monkeys.count)
                for _ in 0..<self.cycles {
                    let deltas = monkeys.map { $0.inspectAndThrowItems() }
                    totals = totals.enumerated().map { $1 + deltas[$0] }
                }
                totals.sort(by: >)
                print("\nMonkey business (after \(self.cycles) rounds): \(totals[0] * totals[1])")
            }
        }
    }
}
