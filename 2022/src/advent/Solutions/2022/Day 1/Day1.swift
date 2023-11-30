// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import System

import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day1: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Calorie Counting")

        @Argument(help: "puzzle input") var input: FilePath

        static func elves(parsing string: String) -> [Elf] {
            return string
                .matches(of: Elf.Parser())
                .map(\.output)
        }

        func run() throws {
            let path = URL(filePath: self.input, directoryHint: .notDirectory)!
            let data = try String(contentsOf: path)

            let elves = Self.elves(parsing: data)
                .sorted(by: { $0.carriedCalories > $1.carriedCalories })

            guard let topElf = elves.first?.carriedCalories else {
                fatalError("There were no elves.")
            }
            let topThree = elves
                .prefix(3)
                .map(\.carriedCalories)
                .reduce(0, +)

            print("Top elf: \(topElf)")
            print("Top three elves: \(topThree)")
        }
    }
}
