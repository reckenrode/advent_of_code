// SPDX-License-Identifier: GPL-3.0-only

import System

import ArgumentParser
import Algorithms

import AdventCommon

extension Solutions.Year2022 {
    struct Day14: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Regolith Reservoir")
        
        @Argument(help: "puzzle input") var input: FilePath

        @Flag(help: "include an infinite floor at the bottom") var floor: Bool = false

        @Flag(help: "display the grid with sand at the end") var showGrid: Bool = false
        @Flag(help: "animate the grid as the sand lands") var animate: Bool = false

        func run() throws {
            let contents = try String(contentsOfFile: self.input.string)
            guard var sandgrid = SandGrid(contentsOf: contents, with: self.floor) else {
                fatalError("Failed to parse the file and create the sand grid")
            }

            sandgrid.dropSand(at: 500)
            while let needMore = sandgrid.process() {
                if needMore {
                    let sandCount = sandgrid.restingSandCount
                    if self.animate {
                        let output = sandgrid.description
                        let newlines = output.filter({ $0 == "\n" }).count
                        if sandgrid.restingSandCount > 1 {
                            print(String(repeating: "\u{1B}[1;A", count: newlines + 3))
                        }
                        print(output)
                        print("Amount of sand on grid: \(sandCount)")
                    } else {
                        print("\u{1B}[100;D\u{1B}[1;AAmount of sand on grid: \(sandCount)")
                    }
                    sandgrid.dropSand(at: 500)
                }
            }

            if self.showGrid && !self.animate { print(sandgrid.description) }
        }
    }
}
