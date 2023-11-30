// SPDX-License-Identifier: GPL-3.0-only

import System

import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day12: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Hill Climbing Algorithm")

        @Argument(help: "puzzle input") var input: FilePath

        @Flag(help: "show path") var showPath: Bool = false
        @Flag(help: "colorize path output") var color: Bool = false
        @Flag(help: "dump the path from the result") var dumpPath: Bool = false

        func prettyPrint(_ map: AreaMap, following path: [Point]) {
            guard let last = path.last else { return }
            if self.showPath {
                var base = map.description
                for (current, next) in path.adjacentPairs() {
                    let currentIndex = base.index(
                        base.startIndex,
                        offsetBy: current.x + current.y * (map.width + 1)
                    )
                    let replacementCharacter: String
                    if current.x == next.x {
                        if current.y > next.y {
                            replacementCharacter = "▲"
                        } else {
                            replacementCharacter = "▼"
                        }
                    } else if current.y == next.y {
                        if current.x > next.x {
                            replacementCharacter = "◀"
                        } else {
                            replacementCharacter = "▶"
                        }
                    } else {
                        replacementCharacter = "?"
                    }
                    base = base.replacingCharacters(
                        in: currentIndex...currentIndex,
                        with: replacementCharacter
                    )
                }
                let puzzleEndIndex = base.index(
                    base.startIndex,
                    offsetBy: last.x + last.y * (map.width + 1)
                )
                base = base.replacingCharacters(
                    in: puzzleEndIndex...puzzleEndIndex,
                    with: "⌧"
                )

                if self.color {
                    // Colorize the output. Requires a terminal capable of displaying truecolor.
                    base = base.replacing(/[a-z]/, with: { "\u{1B}[38;2;64;192;64m\($0.output)" })
                    base = base.replacing(/[▲▼◀▶?⌧]/, with: { "\u{1B}[38;2;192;0;0m\($0.output)" })
                    base.append("\u{1B}[38;2;0;0;0m")
                    print(base)
                }
            }
        }

        func dump(path: [Point]) {
            if self.dumpPath {
                print("[")
                path.forEach { print("    \($0),") }
                print("]")
            }
        }

        func run() throws {
            let puzzle = try AreaMap.load(contentsOfFile: self.input)

            let path = puzzle.map.findPath(from: puzzle.start, to: puzzle.end)
            guard path.count > 0 else {
                fatalError("There is no path to the position with the best signal")
            }

            print("Steps required to reach the position (from the given start): \(path.count - 1)")

            prettyPrint(puzzle.map, following: path)
            dump(path: path)

            let starts = (0..<puzzle.map.height)
                .flatMap { row in return (0..<puzzle.map.width).map { Point(x: $0, y: row) } }
                .filter { puzzle.map[$0] == ("a" as Character).asciiValue! }

            let shortestA = starts
                .map { puzzle.map.findPath(from: $0, to: puzzle.end) }
                .filter { $0.count != 0 }
                .min { $0.count < $1.count }
            guard let shortestA else { fatalError("The map had no a-elevations. How odd.") }

            print(
                "Steps required to reach the position (from the shortest a): \(shortestA.count - 1)"
            )

            prettyPrint(puzzle.map, following: shortestA)
            dump(path: shortestA)
        }
    }
}
