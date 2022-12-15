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
                in: extrema.min.x...extrema.max.x,
                beacons: Set(sensors.map(\.detectedBeacon))
            )
            print("Positions that cannot contain a beacon in row \(self.checkRow): \(coverage)")

            guard
                let signalPosition = findSignalPosition(with: sensors, in: 0...self.upperBound)
            else { fatalError("Signal not found") }

            print("Tuning frequency: \(signalPosition.x * self.freqMult + signalPosition.y)")
        }

        // MARK: - Puzzle stuff

        func countCoverage(
            by sensors: [Sensor],
            at row: Int,
            in bounds: ClosedRange<Int>,
            beacons: Set<Point>
        ) -> Int {
            var result = 0
            for x in bounds {
                for sensor in sensors {
                    guard result != bounds.count else { return result }

                    let point = Point(x: x, y: row)
                    let shouldIncrement = !beacons.contains(point)
                        && sensor.position.taxicabDistance(to: point) <= sensor.radius

                    if shouldIncrement {
                        result += 1
                        break
                    }
                }
            }
            return result
        }

        func findSignalPosition(with sensors: [Sensor], in bounds: ClosedRange<Int>) -> Point? {
            for y in bounds {
                let spans = coalesce(spans: renderSpans(for: y, with: sensors, clampedTo: bounds))
                let gaps = findGaps(in: spans, clampedTo: bounds)
                if gaps.count > 0 {
                    return Point(x: gaps[0].lowerBound, y: y)
                }
            }
            return nil
        }

        // MARK: - Utilities

        func coalesce(spans: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
            let spans = spans.sorted { lhs, rhs in
                return lhs.lowerBound < rhs.lowerBound
                || (lhs.lowerBound == rhs.lowerBound && lhs.upperBound < rhs.upperBound)
            }

            guard var current = spans.first else { return [] }
            var result: [ClosedRange<Int>] = spans[1...].reduce(into: []) { acc, span in
                if current.isDisjoint(with: span) {
                    acc.append(current)
                    current = span
                } else {
                    current = current.lowerBound...max(current.upperBound, span.upperBound)
                }
            }
            result.append(current)

            return result
        }

        func findGaps(
            in spans: [ClosedRange<Int>],
            clampedTo bounds: ClosedRange<Int>
        ) -> [ClosedRange<Int>] {
            var result: [ClosedRange<Int>] = []

            var x = bounds.lowerBound
            var index = spans.startIndex
            while index < spans.endIndex, x < bounds.upperBound {
                let span = spans[index]
                if x < span.lowerBound {
                    result.append(x...(span.lowerBound - 1))
                    x = span.upperBound + 1
                    index = spans.index(after: index)
                } else if span.contains(x) {
                    x = span.upperBound + 1
                    index = spans.index(after: index)
                } else {
                    index = spans.index(after: index)
                }
            }

            return result
        }

        func renderSpans(
            for row: Int,
            with sensors: [Sensor],
            clampedTo bounds: ClosedRange<Int>
        ) -> [ClosedRange<Int>] {
            let resultSet: Set<ClosedRange<Int>> = sensors
                .reduce(into: []) { acc, sensor in
                    let offset = sensor.radius - abs(row - sensor.position.y)
                    let lowerBound = sensor.position.x - offset
                    let upperBound = sensor.position.x + offset
                    if lowerBound <= upperBound {
                        acc.insert((lowerBound...upperBound).clamped(to: bounds))
                    }
                }
            return Array(resultSet)
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
