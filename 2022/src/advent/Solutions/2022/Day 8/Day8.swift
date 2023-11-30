// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

extension Solutions.Year2022 {
    struct Day8: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Treetop Tree House")

        @Argument(help: "puzzle input") var input: FilePath
        @Option(help: "print visibility grid") var printGrid: Bool = false

        func read(file: FilePath) throws -> [[Int]] {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else {
                return []
            }
            return try String(contentsOf: fileUrl)
                .split(separator: /\n/)
                .map { line in
                    let digits = line.matches(of: TryCapture(.digit, transform: { Int($0) }))
                    return digits.map { $0.1 }
                }
        }

        func calculateScenicScore(in forest: [[Int]]) -> [[Int]] {
            precondition(
                forest.reduce(true) { $0 && $1.count == forest[0].count },
                "forest must be a rectangular (non-jagged) array"
            )
            let width = forest[0].count
            let height = forest.count

            return Array(unsafeUninitializedCapacity: height) { memory, rowCount in
                for row in 0..<height {
                    memory[row] = Array(unsafeUninitializedCapacity: width) { rowMem, columnCount in
                        for col in 0..<width {
                            let pt = forest[row][col]
                            let up = countTreesSeen(
                                from: pt,
                                along: stride(from: row - 1, through: 0, by: -1)
                                    .map { forest[$0][col] }
                            )
                            let down = countTreesSeen(
                                from: pt,
                                along: ((row + 1)..<height).map { forest[$0][col] }
                            )
                            let left = countTreesSeen(
                                from: pt,
                                along: stride(from: col - 1, through: 0, by: -1)
                                    .map { forest[row][$0] }
                            )
                            let right = countTreesSeen(
                                from: pt,
                                along: ((col + 1)..<width).map { forest[row][$0] }
                            )
                            rowMem[col] = up * down * left * right
                        }
                        columnCount = width
                    }
                }
                rowCount = height
            }
        }

        func countTreesSeen(from height: Int, along range: [Int]) -> Int {
            let numTrees = range.prefix(while: { $0 < height }).count
            return numTrees + (numTrees != range.count ? 1 : 0)
        }

        func identifyVisibleTrees(in forest: [[Int]]) -> [[Bool]] {
            precondition(
                forest.reduce(true) { $0 && $1.count == forest[0].count },
                "forest must be a rectangular (non-jagged) array"
            )
            let width = forest[0].count
            let height = forest.count

            var topMaxIndices: [Set<Int>] = Array(repeating: [0], count: width)
            var botMaxIndices: [Set<Int>] = Array(repeating: [height - 1], count: width)
            var lhsMaxIndices: [Set<Int>] = Array(repeating: [0], count: height)
            var rhsMaxIndices: [Set<Int>] = Array(repeating: [width - 1], count: height)

            for row in 0..<width {
                for col in 0..<height {
                    let revRow = height - row - 1
                    let revCol = width - col - 1

                    if topMaxIndices[col].allSatisfy({ forest[row][col] > forest[$0][col] }) {
                        topMaxIndices[col].insert(row)
                    }
                    if botMaxIndices[col].allSatisfy({ forest[revRow][col] > forest[$0][col] }) {
                        botMaxIndices[col].insert(revRow)
                    }
                    if lhsMaxIndices[row].allSatisfy({ forest[row][col] > forest[row][$0] }) {
                        lhsMaxIndices[row].insert(col)
                    }
                    if rhsMaxIndices[row].allSatisfy({ forest[row][revCol] > forest[row][$0] }) {
                        rhsMaxIndices[row].insert(revCol)
                    }
                }
            }

            return Array(unsafeUninitializedCapacity: height) { memory, rowCount in
                for row in 0..<height {
                    memory[row] = Array(unsafeUninitializedCapacity: width) { rowMemory, columns in
                        for column in 0..<width {
                            let isInMaxColumn = lhsMaxIndices[row].contains(column)
                                || rhsMaxIndices[row].contains(column)
                            let isInMaxRow = topMaxIndices[column].contains(row)
                                || botMaxIndices[column].contains(row)
                            rowMemory[column] = isInMaxRow || isInMaxColumn
                        }
                        columns = width
                    }
                }
                rowCount = height
            }
        }

        func run() throws {
            let forest = try read(file: self.input)

            let visible = identifyVisibleTrees(in: forest)

            if self.printGrid {
                for r in 0..<5 {
                    for c in 0..<5 {
                        if visible[r][c] {
                            print("T", terminator: "")
                        } else {
                            print("F", terminator: "")
                        }
                    }
                    print("")
                }
            }

            let numVisible = visible.reduce(0) { $0 + $1.filter { $0 }.count }
            print("The number of tallest trees is: \(numVisible)")

            let scenicScores = calculateScenicScore(in: forest)
            let highestScore = scenicScores.reduce(0) { max($0, $1.max() ?? 0) }
            print("Highest scenic score: \(highestScore)")
        }
    }
}
