// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

import Collections

import AdventCommon

struct RockField {
    private static let fieldWidth = 7

    private static let safetyMargin = dropOffset + 4 /* Tallest shape */
    private static let dropOffset = 3

    // MARK: - Storage Implementation

    private var storage: [UInt8] = Array(repeating: 0, count: safetyMargin)

    private var count: Int { self.storage.count }

    private func index(at offset: Int) -> UInt8 {
        return self.storage[offset]
    }

    private func index(at offset: Int) -> UInt32 {
        return UInt32(self.storage[offset])
    }

    mutating private func modify(at offset: Int, _ body: (inout UInt8) -> Void) {
        body(&self.storage[offset])
    }

    mutating private func append(_ element: UInt8) {
        self.storage.append(element)
    }

    mutating private func append(contentsOf sequence: some Sequence<UInt8>) {
        self.storage.append(contentsOf: sequence)
    }

    private func reversed() -> some Sequence<UInt8> {
        return sequence(state: self.count - Self.safetyMargin - 1) { index in
            guard index >= 0 else { return nil }
            defer { index -= 1 }
            return self.index(at: index)
        }
    }

    // MARK: - Display

    var description: String {
        let contents = self.reversed().lazy
            .map { "\(binary: $0)".dropFirst(1).reversed() }
            .joined(by: "\n")
        return String(contents)
            .replacing("0", with: ".")
            .replacing("1", with: "#")
    }

    // MARK: - Rock Constants

    enum Rock: CaseIterable {
        enum MovementDirection: String, RawRepresentable {
            case left = "<", right = ">", down = "v"

            var offset: Offset {
                switch self {
                case .left:
                    return Offset(x: -1, y: 0)
                case .right:
                    return Offset(x: 1, y: 0)
                case .down:
                    return Offset(x: 0, y: -1)
                }
            }
        }

        case hBar, plus, lBlock, vBar, square

        fileprivate var wordPattern: UInt32 {
            switch self {
            case .hBar:
                return 0b00001111000000000000000000000000
            case .plus:
                return 0b00000010000001110000001000000000
            case .lBlock:
                return 0b00000111000001000000010000000000
            case .vBar:
                return 0b00000001000000010000000100000001
            case .square:
                return 0b00000011000000110000000000000000
            }
        }

        // MARK: - Rock Properties

        var height: Int {
            switch self {
            case .hBar:
                return 1
            case .square:
                return 2
            case .plus, .lBlock:
                return 3
            case .vBar:
                return 4
            }
        }

        var width: Int {
            switch self {
            case .vBar:
                return 1
            case .square:
                return 2
            case .plus, .lBlock:
                return 3
            case .hBar:
                return 4
            }
        }

        // MARK: - Rock Tests

        func intersects(with field: RockField, at point: Point) -> Bool {
            guard point.x >= 0, (point.x + self.width) <= field.width else { return true }
            guard point.y >= 0 else { return true }

            let offset = point.y
            let slice: UInt32 =
                  field.index(at: offset)   << 24
                | field.index(at: offset+1) << 16
                | field.index(at: offset+2) << 8
                | field.index(at: offset+3)

            return (self.wordPattern &<< point.x) & slice != 0
        }
    }

    // MARK: - Rock Movement

    /// The point is the bottom left point of the rock’s hit-box.
    mutating func drop(rock: Rock) {
        guard self.fallingRock == nil else { return }

        self.fallingRock = (rock, Point(x: 2, y: self.height + Self.dropOffset))
    }

    /// Returns false if the rock does not exist or has stopped moving
    mutating func moveRock(_ direction: Rock.MovementDirection) {
        guard let obj = self.fallingRock else { return }

        let newPosition = obj.position + direction.offset
        guard obj.rock.intersects(with: self, at: newPosition) else {
            self.fallingRock = (rock: obj.rock, position: newPosition)
            return
        }

        if case .down = direction {
            self.put(rock: obj.rock, at: obj.position)
            self.fallingRock = nil
        }
    }

    // MARK: - Field Manipulation

    mutating func put(rock: Rock, at point: Point) {
        let extraRows = point.y + rock.height - self.height

        if extraRows > 0 {
            self.append(contentsOf: (0..<extraRows).lazy.map { _ in 0 } )
        }

        let offset = point.y
        var slice: UInt32 = self.index(at: offset)   << 24 | self.index(at: offset+1) << 16
        slice |= self.index(at: offset+2) << 8 | self.index(at: offset+3)
        slice |= (rock.wordPattern << point.x)

        self.modify(at: point.y)   { $0 = UInt8(truncatingIfNeeded: slice >> 24) }
        self.modify(at: point.y+1) { $0 = UInt8(truncatingIfNeeded: slice >> 16) }
        self.modify(at: point.y+2) { $0 = UInt8(truncatingIfNeeded: slice >> 8) }
        self.modify(at: point.y+3) { $0 = UInt8(truncatingIfNeeded: slice) }
    }

    // MARK: - Field Properties

    let width: Int = 7
    var height: Int { self.count - Self.safetyMargin } /// Always equal to the top of the highest block

    var fallingRock: (rock: Rock, position: Point)? = nil

    func findCycle() -> (offset: Int, size: Int)? {
        let str = self.storage[..<self.height].map({ String(format: "%02x", $0) }).joined()
        let strCount = str.count

        var startIndex = str.startIndex
        var segmentStart = str.index(startIndex, offsetBy: strCount / 2)
        let endIndex = segmentStart

        while startIndex < endIndex {
            if str[startIndex..<segmentStart] == str[segmentStart...] {
                return (
                    offset: str.distance(from: str.startIndex, to: startIndex) / 2,
                    size: str.distance(from: startIndex, to: segmentStart) / 2
                )
            }
            startIndex = str.index(startIndex, offsetBy: 2)
            segmentStart = str.index(segmentStart, offsetBy: 1)
        }
        return nil
    }
}
