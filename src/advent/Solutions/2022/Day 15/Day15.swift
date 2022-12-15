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
                let spans = renderSpans(for: y, with: sensors, clampedTo: bounds)
                let gaps = findGaps(in: spans)
                if gaps.count > 0 {
                    return Point(x: gaps[0].lowerBound, y: y)
                }
            }
            return nil
        }

        // MARK: - Span rendering

        func coalesce(spans: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
            func loop(
                over slice: Array<ClosedRange<Int>>.SubSequence,
                current: ClosedRange<Int>,
                result: List<ClosedRange<Int>>
            ) -> [ClosedRange<Int>] {
                guard let span = slice.first else { return List.cons(current, result).reversed() }

                let next = slice[slice.index(after: slice.startIndex)...]
                if !current.overlaps(span) {
                    return loop(over: next, current: span, result: .cons(current, result))
                } else {
                    return loop(
                        over: next,
                        current: current.lowerBound...max(current.upperBound, span.upperBound),
                        result: result
                    )
                }
            }

            guard let first = spans.first else { return [] }

            let nextIndex = spans.index(after: spans.startIndex)
            return loop(over: spans[nextIndex...], current: first, result: .empty)
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
            func loop(
                over slice: Array<ClosedRange<Int>>.SubSequence,
                at position: Int,
                result: List<ClosedRange<Int>>
            ) -> [ClosedRange<Int>] {
                guard let span = slice.first else { return result.reversed() }

                let next = slice[slice.index(after: slice.startIndex)...]
                if position < span.lowerBound {
                    return loop(
                        over: next,
                        at: span.upperBound + 1,
                        result: .cons(position...(span.lowerBound - 1), result)
                    )
                } else if span.contains(position) {
                    return loop(over: next, at: span.upperBound + 1, result: result)
                } else {
                    return loop(over: next, at: position, result: result)
                }
            }
            guard let first = spans.first else { return [] }

            return loop(
                over: spans[spans.index(after: spans.startIndex)...],
                at: first.upperBound + 1,
                result: .empty
            )
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
