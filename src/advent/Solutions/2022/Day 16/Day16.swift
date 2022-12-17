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
        @Option(help: "starting valve") var startValve: String = "AA"

        func run() throws {
            let data = try String(contentsOfFile: self.input.string)
            guard let network = CaveNetwork(contentsOf: data) else {
                fatalError("File did not contain cave layout data")
            }

            let maxPressure = maxPressureReleasable(
                in: network,
                over: self.timer,
                startingAt: self.startValve
            )
            print("Pressure over \(self.timer)m starting at ‘\(self.startValve)’: \(maxPressure)")
        }

        // MARK: - Puzzle Solution

        func maxPressureReleasable(
            in network: CaveNetwork,
            over time: Int,
            startingAt valve: String,
            withOpened valves: TreeDictionary<String, Int> = [:],
            accumulated pressure: Int = 0
        ) -> Int {
            guard time > 0 else { return pressure }

            let current = (network[valve] > 0 && valves[valve] == nil) ? [valve] : []
            let valveCandidates = chain(current, network.neighbors(of: valve))
                .filter {
                    network[$0] > 0 && valves[$0] == nil
                    && (time - network.distance(from: valve, to: $0) - 1 > 0)
                }

            guard valveCandidates.count > 0 else {
                return pressure + valves.values.reduce(0, +) * time
            }

            return valveCandidates
                .reduce(0) { maxPressure, candidates in
                    var candidateValves = valves
                    candidateValves[candidates] = network[candidates]

                    // Travel to the valve and open it
                    let candidateDistance = network.distance(from: valve, to: candidates)
                    let candidateTime = time - candidateDistance - 1

                    // Pressure continues to release while traveling and opening the valve
                    let candidatePressure = pressure
                        + valves.values.reduce(0, +) * (candidateDistance + 1)

                    let newPressure = maxPressureReleasable(
                        in: network,
                        over: candidateTime,
                        startingAt: candidates,
                        withOpened: candidateValves,
                        accumulated: candidatePressure// + accumulatedPressure
                    )
                    return newPressure > maxPressure ? newPressure : maxPressure
                }
        }
    }
}
