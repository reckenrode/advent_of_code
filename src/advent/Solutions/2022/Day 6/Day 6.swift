// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

import ArgumentParser

extension Solutions.Year2022 {
    struct Day6: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Tuning Trouble")

        @Argument(help: "puzzle input") var input: FilePath

        func read(file: FilePath) throws -> String {
            guard let fileUrl = URL(filePath: file, directoryHint: .notDirectory) else { return "" }
            return try String(contentsOf: fileUrl)
        }

        enum CommType: Int, RawRepresentable {
            case packet = 4
            case message = 14
        }

        func findStart<S: StringProtocol>(of comm: CommType, in text: S) -> Int
            where S: BidirectionalCollection, S.SubSequence == Substring
        {
            let regex = Regex {
                let maybePacket = Repeat("a"..."z", count: comm.rawValue)
                TryCapture(maybePacket, transform: { capturedText -> Int? in
                    guard Set(capturedText).count == comm.rawValue else { return nil }
                    return text.distance(
                        from: text.startIndex,
                        to: capturedText.endIndex
                    )
                })
            }

            guard let offset = text.firstMatch(of: regex) else {
                fatalError("No start-of-\(comm) marker detected")
            }

            return offset.output.1
        }

        func run() throws {
            let puzzle = try read(file: self.input)

            let packetBound = findStart(of: .packet, in: puzzle)
            print("First start-of-packet market: \(packetBound)")

            let messageBound = findStart(of: .message, in: puzzle)
            print("First start-of-packet market: \(messageBound)")
        }
    }
}
