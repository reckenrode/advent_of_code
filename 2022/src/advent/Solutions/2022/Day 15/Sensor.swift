// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

import AdventCommon

struct Sensor {
    let position: Point
    let detectedBeacon: Point
    let radius: Int

    // MARK: - Parsing

    init?<S: StringProtocol & BidirectionalCollection>(
        contentsOf string: S
    ) where S.SubSequence == Substring {
        let regex = Regex {
            let number = TryCapture(/-?\d+/) { Int($0) }
            let point = Regex { "x="; number; ", y="; number }
            "Sensor at "; point; ": closest beacon is at "; point
        }
        guard
            let (_, sensorX, sensorY, beaconX, beaconY) = string.firstMatch(of: regex)?.output
        else { return nil }

        self.position = Point(x: sensorX, y: sensorY)
        self.detectedBeacon = Point(x: beaconX, y: beaconY)
        self.radius = self.position.taxicabDistance(to: self.detectedBeacon)
    }
}
