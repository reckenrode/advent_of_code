// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder
import System

import ArgumentParser

import AdventCommon

extension Solutions.Year2022 {
    struct Day18: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Boiling Boulders")

        @Argument(help: "puzzle input") var input: FilePath

        func run() throws {
            let data = try String(contentsOfFile: self.input.string)
            let droplet = VoxelGrid(contentsOf: data)

            print("Surface area of the obsidian: \(droplet.surfaceArea)")
            print("External surface area of the obsidian: \(droplet.externalSurfaceArea)")
        }

        // MARK: - Puzzle Solution


    }
}
