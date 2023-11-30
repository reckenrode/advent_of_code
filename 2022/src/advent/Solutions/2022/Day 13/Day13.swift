// SPDX-License-Identifier: GPL-3.0-only

import System

import ArgumentParser
import Algorithms

import AdventCommon

extension Solutions.Year2022 {
    struct Day13: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Distress Signal")

        @Argument(help: "puzzle input") var input: FilePath

        @Flag(help: "dump each pair and whether it is ordered correctly") var debug = false

        func run() throws {
            let pairs = try String(contentsOfFile: self.input.string).split(separator: "\n\n")
                .map { (rawPair: Substring) in
                    let pair = rawPair.split(separator: /\n/)
                    guard
                        let lhs = PacketData(contentsOf: pair[0]),
                        let rhs = PacketData(contentsOf: pair[1])
                    else { fatalError("Failed to parse packet data") }
                    return (lhs, rhs)
                }

            let indexSums = pairs.enumerated().reduce(0) { acc, pair in
                let (index, (lhs, rhs)) = pair
                return acc + (lhs.isOrderedCorrectly(comparedTo: rhs) ? index + 1 : 0)
            }
            print("Sum of indices belonging to correctly ordered pairs: \(indexSums)")

            if self.debug {
                for pair in pairs.enumerated() {
                    let (index, (lhs, rhs)) = pair
                    print("\nPair #\(index + 1)")
                    print(lhs.description)
                    print(rhs.description)
                    print("Ordered correctly? \(lhs.isOrderedCorrectly(comparedTo: rhs))")
                }
            }

            let dividerPackets: Set<PacketData> = [
                [[2]],
                [[6]],
            ]

            let packets = chain(dividerPackets, pairs.flatMap { [$0.0, $0.1] })
                .sorted { $0.ordering(comparedTo: $1) == .orderedDescending }

            let decoderKey = packets.enumerated().filter { dividerPackets.contains($1) }
            print("Decoder key: \((decoderKey[0].offset + 1) * (decoderKey[1].offset + 1))")
        }
    }
}
