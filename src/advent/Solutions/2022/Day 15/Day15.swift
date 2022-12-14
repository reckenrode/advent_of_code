// SPDX-License-Identifier: GPL-3.0-only

import System

import ArgumentParser
import Collections

import AdventCommon

extension Solutions.Year2022 {
    struct Day15: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Beacon Exclusion Zone")

        @Argument(help: "puzzle input") var input: FilePath

        @Option(help: "row to check for inelligible positions") var checkRow: Int = 2000000
        @Option(help: "tuning frequency multiplier for distress signal") var freqMult: Int = 4000000
        @Option(help: "upper bound on search area") var upperBound: Int = 4000000

        func run() throws {
            let contents = try String(contentsOfFile: self.input.string)

            let lines = contents.split(separator: /\n/)
            let sensors = lines.compactMap(Sensor.init(contentsOf:))

            guard lines.count == sensors.count else { fatalError("Not all sensors were parsed") }

            let extrema = findExtrema(of: sensors)

            let coverage = countCoverage(
                by: sensors,
                at: self.checkRow,
                in: extrema.min.x...extrema.max.x
            )
            print("Positions that cannot contain a beacon in row \(self.checkRow): \(coverage)")

            guard
                let signalPosition = findSignalPosition(with: sensors, in: 0...self.upperBound)
            else { fatalError("Signal not found") }

            print("Tuning frequency: \(signalPosition.x * self.freqMult + signalPosition.y)")
        }

        // MARK: - Puzzle stuff

        func countCoverage(by sensors: [Sensor], at row: Int, in bounds: ClosedRange<Int>) -> Int {
            let beacons = Set(
                sensors.compactMap { $0.detectedBeacon.y == row ? $0.detectedBeacon.x : nil }
            )
            let spans = renderSpans(for: row, with: sensors, clampedTo: bounds)
            return spans.reduce(0) { acc, span in
                let beaconsInSpan = beacons.lazy.filter(span.contains)
                return acc + span.count - beaconsInSpan.count
            }
        }

        func findSignalPosition(with sensors: [Sensor], in bounds: ClosedRange<Int>) -> Point? {
            return bounds.lazy
                .compactMap { y in
                    let spans = renderSpans(for: y, with: sensors, clampedTo: bounds)
                    let gaps = findGaps(in: spans)
                    guard gaps.count > 0 else { return nil }

                    return Point(x: gaps[0].lowerBound, y: y)
                }
                .first
        }

        // MARK: - Span rendering

        func coalesce(spans: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
            guard let first = spans.first else { return [] }

            let (current, result): (ClosedRange<Int>, List<ClosedRange<Int>>) = spans[1...]
                .reduce((first, .empty)) { state, span in
                    let (current, result) = state
                    if !current.overlaps(span) {
                        return (span, .cons(current, result))
                    } else {
                        return (
                            current.lowerBound...max(current.upperBound, span.upperBound),
                            result
                        )
                    }
                }
            return List.cons(current, result).reversed()
        }

        func renderSpans(
            for row: Int,
            with sensors: [Sensor],
            clampedTo bounds: ClosedRange<Int>
        ) -> [ClosedRange<Int>] {
            let spans: [ClosedRange<Int>] = sensors
                .compactMap { sensor in
                    let offset = sensor.radius - abs(row - sensor.position.y)
                    let lowerBound = sensor.position.x - offset
                    let upperBound = sensor.position.x + offset
                    guard lowerBound <= upperBound else { return nil }
                    return (lowerBound...upperBound).clamped(to: bounds)
                }
                .sorted { lhs, rhs in
                    return lhs.lowerBound < rhs.lowerBound
                    || (lhs.lowerBound == rhs.lowerBound && lhs.upperBound < rhs.upperBound)
                }
            return coalesce(spans: spans)
        }


        // MARK: - Utilities

        func findGaps(in spans: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
            guard let first = spans.first else { return [] }

            let (_, result): (Int, List<ClosedRange<Int>>) = spans[1...]
                .reduce((first.upperBound + 1, .empty)) { state, span in
                    let (position, result) = state
                    if position < span.lowerBound {
                        return (
                            span.upperBound + 1,
                            .cons(position...(span.lowerBound - 1), result)
                        )
                    } else if span.contains(position) {
                        return (span.upperBound + 1, result)
                    } else {
                        return state
                    }
                }
            return result.reversed()
        }

        func largestArea(around sensor: Sensor) -> (min: Point, max: Point) {
            let position = sensor.position
            let radius = position.taxicabDistance(to: sensor.detectedBeacon)

            return (
                Point(x: position.x - radius, y: position.y - radius),
                Point(x: position.x + radius, y: position.y + radius)
            )
        }

        func findExtrema(of sensors: [Sensor]) -> (min: Point, max: Point) {
            guard let firstSensor = sensors.first else { fatalError("Sensors list empty") }

            return sensors[1...]
                .reduce(largestArea(around: firstSensor)) { (acc, sensor) in
                    let area = largestArea(around: sensor)
                    return (
                        min: Point(
                            x: min(acc.min.x, area.min.x),
                            y: min(acc.min.y, area.min.y)
                        ),
                        max: Point(
                            x: max(acc.max.x, area.max.x),
                            y: max(acc.max.x, area.max.y)
                        )
                    )
                }
        }
    }
}
