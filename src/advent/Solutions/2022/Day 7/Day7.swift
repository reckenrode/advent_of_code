// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import System

import ArgumentParser

extension Solutions.Year2022 {
    struct Day7: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "No Space Left On Device")

        @Argument(help: "puzzle input") var input: FilePath

        @Argument(help: "desired free space") var freeSpace: UInt64 = 30000000
        @Argument(help: "filesystem size") var fsSize: UInt64 = 70000000

        func read(file: FilePath) throws -> FileSystem? {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else {
                return nil
            }
            let commands = try String(contentsOf: fileUrl)

            return FileSystem(from: commands)
        }

        func run() throws {
            guard let fs = try read(file: self.input) else {
                fatalError("Error reading file")
            }

            let dirs = try fs.directories
            let dirSizes = try dirs.map { try fs.sizeOf(try fs.stat($0)) }

            let totalSizeSmallDirs = dirSizes
                .filter { $0 <= 100000 }
                .reduce(0, +)
            print("The total size of small directories (≤100,000): \(totalSizeSmallDirs)")

            let availableSpace = try self.fsSize - fs.sizeOf(fs.stat("/"))
            let sortedSizes = dirSizes.sorted(by: <)
            let deletionCandidate = sortedSizes.first { availableSpace + $0 >= self.freeSpace }!
            print("Size of the directory to delete: \(deletionCandidate)")
        }
    }
}
