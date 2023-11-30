// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day2: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Rock Paper Scissors")

        @Argument(help: "puzzle input") var input: FilePath

        func plays(parsing file: FilePath) throws -> [(Substring, Substring)] {
            guard let path = URL(filePath: file, directoryHint: .notDirectory) else { return [] }

            let content = try String(contentsOf: path)
            return content
                .matches(of: /([ABC]) ([XYZ])\n/)
                .map { ($0.1, $0.2) }
        }

        func run() throws {
            let (scoreMethod1, scoreMethod2) = try plays(parsing: self.input)
                .map { play in
                    let (them, me) = play

                    let firstScore = me.score(against: them)
                    let myPlay = me.shouldPlay(against: them)
                    let secondScore = myPlay.score(against: them)

                    return (firstScore, secondScore)
                }
                .unzip()

            print("Total score (my way): \(scoreMethod1.reduce(0, +))")
            print("Total score (elf way): \(scoreMethod2.reduce(0, +))")
        }
    }
}

fileprivate let playValues = ["A": 1, "B": 2, "C": 3, "X": 1, "Y": 2, "Z": 3]


extension StringProtocol {
    fileprivate func score(against other: Self) -> Int {
        let selfPlay = ["X": "A", "Y": "B", "Z": "C"][self] ?? String(self)
        switch (selfPlay, other) {
        case ("B", "A"), ("A", "C"), ("C", "B"):
            return 6 + (playValues[selfPlay] ?? 0)
        case ("A", "A"), ("B", "B"), ("C", "C"):
            return 3 + (playValues[selfPlay] ?? 0)
        default:
            return 0 + (playValues[selfPlay] ?? 0)
        }
    }

    fileprivate func shouldPlay(against other: Self) -> Self {
        switch (self, other) {
        case ("Z", "A"), ("X", "C"), ("Y", "B"):
            return "B"
        case ("Z", "B"), ("X", "A"), ("Y", "C"):
            return "C"
        case ("Z", "C"), ("X", "B"), ("Y", "A"):
            return "A"
        default:
            fatalError("Unexpected RPS instruction.")
        }
    }
}
