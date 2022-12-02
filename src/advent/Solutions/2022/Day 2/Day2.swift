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

        func plays(parsing file: FilePath) throws -> [(RPSPlay, RPSPlay, RPSOutcome)] {
            guard let path = URL(filePath: file, directoryHint: .notDirectory) else { return [] }

            let content = try String(contentsOf: path)
            return content
                .matches(of: Regex {
                    TryCapture("A"..."C", transform: RPSPlay.init)
                    " "
                    TryCapture("X"..."Z", transform: { string -> (RPSPlay, RPSOutcome)? in
                        guard let play = RPSPlay(parsing: string) else { return nil }
                        guard let outcome = RPSOutcome(parsing: string) else { return nil }
                        return (play, outcome)
                    })
                    One(.newlineSequence)
                })
                .map { ($0.1, $0.2.0, $0.2.1) }
        }

        func run() throws {
            let plays = try plays(parsing: self.input)
            let (scoreMethod1, scoreMethod2) = plays
                .map { round in
                    let (theirPlay, myPlay, desiredOutcome) = round

                    let firstScore = myPlay.score(against: theirPlay)

                    let myNewPlay = desiredOutcome.shouldPlay(against: theirPlay)
                    let secondScore = myNewPlay.score(against: theirPlay)

                    return (firstScore, secondScore)
                }
                .unzip()

            print("Total score (my way): \(scoreMethod1.reduce(0, +))")
            print("Total score (elf way): \(scoreMethod2.reduce(0, +))")
        }
    }
}
