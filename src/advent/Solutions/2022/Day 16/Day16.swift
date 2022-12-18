// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import System

import Algorithms
import ArgumentParser
import Collections

import AdventCommon

extension Solutions.Year2022 {
    struct Day16: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Proboscidea Volcanium")
        
        @Argument(help: "puzzle input") var input: FilePath

        @Option(help: "time in minutes before the erruption") var timer: Int = 30

        @Option(help: "number of elephants helping") var elephants: Int = 0
        @Option(help: "time delay teaching helpers how to search") var teachingTime: Int = 0

        func run() throws {
            let data = try String(contentsOfFile: self.input.string)
            guard let network = CaveNetwork(contentsOf: data) else {
                fatalError("File did not contain cave layout data")
            }

            let pressure = maxPressureReleasable(
                in: network,
                over: self.timer - self.teachingTime,
                startingAt: Array(repeating: network.firstValve, count: self.elephants + 1)
            )
            print("Pressure over \(self.timer)m starting at ‘\(network.firstValve)’: \(pressure)")
        }

        // MARK: - Puzzle Solution

        func maxPressureReleasable(
            in network: CaveNetwork,
            over time: Int,
            startingAt startValves: [String],
            withOpened valves: TreeDictionary<String, Int> = [:],
            landingIndex: TreeDictionary<Int, [String]> = [:]
        ) -> Int {
            let valveCandidates = startValves
                .map { startValve in
                    let withStart = network[startValve] > 0 && valves[startValve] == nil
                        ? [startValve]
                        : []
                    let candidates = chain(withStart, network.neighbors(of: startValve))
                        .filter {
                            network[$0] > 0 && valves[$0] == nil
                            && (time - network.distance(from: startValve, to: $0) - 1 > 0)
                        }
                    return (startValve: startValve, candidates: Set(candidates))
                }
                .filter { $0.candidates.count > 0 }

            guard time > 0, valveCandidates.count > 0 else {
                return valves.totalPressure(in: network)
            }

            let commonCandidates = valveCandidates
                .reduce(valveCandidates[0].candidates) { acc, pair in
                    let (_, candidates) = pair
                    return acc.intersection(candidates)
                }

            let uncommonCandidates: [String: Set<String>] = Dictionary(
                valveCandidates.compactMap { pair in
                    let (startValve, candidates) = pair
                    let uncommon = candidates.symmetricDifference(commonCandidates)
                    guard uncommon.count > 0 else { return nil }
                    return (startValve, uncommon)
                },
                uniquingKeysWith: { _, _ in fatalError("There should be no duplicates") }
            )

            let startCandidates = valveCandidates.map(\.startValve)

            let permutations: any Sequence<[String]>
            if valveCandidates.count == 1 {
                permutations = commonCandidates.map { Array(arrayLiteral: $0) }
            } else {
                permutations = commonCandidates.uniquePermutations(ofCount: startCandidates.count)
            }

            let uncommonResults = uncommonCandidates
                .flatMap { startValve, candidates in
                    candidates.map { candidate in
                        var nextOpened = valves
                        var nextIndex = landingIndex

                        let distance = network.distance(from: startValve, to: candidate)
                        let emissionStart = time - distance - 1

                        nextOpened[candidate] = emissionStart
                        nextIndex[emissionStart, default: []].append(candidate)

                        let (_, nextArrivalTime) = nextOpened
                            .filter { $0.value < time }
                            .max(by: { $0.value < $1.value })!

                        let nextStart = nextIndex[nextArrivalTime, default: []]
                        return maxPressureReleasable(
                            in: network,
                            over: nextArrivalTime,
                            startingAt: nextStart,
                            withOpened: nextOpened,
                            landingIndex: nextIndex
                        )
                    }
                }

            let commonResults = permutations
                .map { candidates in
                    var nextOpened = valves
                    var nextIndex = landingIndex

                    zip(startCandidates, candidates).forEach { startValve, candidate in
                        let distance = network.distance(from: startValve, to: candidate)
                        let emissionStart = time - distance - 1

                        nextOpened[candidate] = emissionStart
                        nextIndex[emissionStart, default: []].append(candidate)
                    }

                    let (_, nextArrivalTime) = nextOpened
                        .filter { $0.value < time }
                        .max(by: { $0.value < $1.value })!

                    let nextStart = nextIndex[nextArrivalTime, default: []]
                    return maxPressureReleasable(
                        in: network,
                        over: nextArrivalTime,
                        startingAt: nextStart,
                        withOpened: nextOpened,
                        landingIndex: nextIndex
                    )
                }

            return chain(uncommonResults, commonResults).max() ?? 0
        }
    }
}

private extension TreeDictionary where Key == CaveNetwork.Index, Value == CaveNetwork.Element {
    func totalPressure(in network: CaveNetwork) -> Int {
        return self.reduce(0) { $0 + network[$1.key] * $1.value}
    }
}
