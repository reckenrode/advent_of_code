// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day4: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Camp Cleanup")

        @Argument(help: "puzzle input") var input: FilePath

        static let assignmentRegex = Regex {
            let sectionNumber = TryCapture(OneOrMore(.digit), transform: { Int($0) })
            let sectionAssignment = Regex {
                sectionNumber; "-"; sectionNumber
            }
            sectionAssignment; ","; sectionAssignment
        }

        func read(file: FilePath) throws -> [(first: ClosedRange<Int>, second: ClosedRange<Int>)] {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else { return [] }

            let contents = try String(contentsOf: fileUrl)
            return contents
                .matches(of: Self.assignmentRegex)
                .map { (first: $0.1...$0.2, second: $0.3...$0.4) }
        }

        func run() throws {
            let assignments = try read(file: self.input)

            let fullyMatched = assignments.filter { assignment in
                assignment.first.contains(assignment.second)
                || assignment.second.contains(assignment.first)
            }
            print("Number of assignments that fully overlap: \(fullyMatched.count)")

            let overlappingMatches = assignments.filter { assignment in
                assignment.first.overlaps(assignment.second)
                || assignment.second.overlaps(assignment.first)
            }
            print("Number of assignments that overlap at all: \(overlappingMatches.count)")
        }
    }
}
