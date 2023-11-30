// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

import AdventCommon
import Algorithms

extension Solutions.Year2022 {
    struct Day5: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Supply Stacks")

        @Argument(help: "puzzle input") var input: FilePath
        @Flag(help: "dump puzzle input") var debug: Bool = false

        func read(file: FilePath) throws -> (CrateStack, [CrateMove]) {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else { return (CrateStack(), []) }

            let contents = try String(contentsOf: fileUrl)
            let raw = contents.split(separator: /\n\n/)

            let stack = CrateStack.Parser.parseStack(from: raw[0])
            let moves = CrateMove.Parser.parseMoves(from: raw[1])

            return (stack, moves)
        }

        func run() throws {
            let (stack, moves) = try read(file: self.input)

            if debug {
                print(stack.description)
                print("")
                print(String(moves.map(\.description).joined(by: "\n")))
            }

            let try1 = stack.movingSingleCrates(following: moves)
            let topCrates1 = String(try1.topCrates.map(\.label))
            print("Crate at the top of each stack (CrateMover 9000): \(topCrates1)")

            let try2 = stack.movingMultipleCrates(following: moves)
            let topCrates2 = String(try2.topCrates.map(\.label))
            print("Crate at the top of each stack (CrateMover 9001): \(topCrates2)")
        }
    }
}
