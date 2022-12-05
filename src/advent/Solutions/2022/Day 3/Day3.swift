// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import System

import Algorithms
import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day3: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Rucksack Reorganization")

        @Argument(help: "puzzle input") var input: FilePath

        func read(file: FilePath) throws -> [Rucksack] {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else { return [] }

            let contents = try String(contentsOf: fileUrl)
            return contents
                .split(separator: /\n/)
                .compactMap(Rucksack.init)
        }

        func run() throws {
            let sacks = try read(file: self.input)

            let priorities = sacks.flatMap(\.priorityItems).map(\.score)
            print("Sum of priorities (by pocket): \(priorities.reduce(0, +))")

            let elfBadges = sacks
                .chunks(ofCount: 3)
                .flatMap { $0[0].shared(with: $0[1...]) }
            let badgePriorities = elfBadges.map(\.score)
            print("Sum of priorities (by group): \(badgePriorities.reduce(0, +))")
        }
    }
}
