// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

struct Item: Equatable, Hashable, CustomDebugStringConvertible {
private var value: UInt8

    static let regex = TryCapture(/[A-Za-z]/, transform: { $0.utf8.first }).regex

    init?(rawValue: Character) {
        guard let asciiValue = try? Self.regex.wholeMatch(in: String(rawValue)) else { return nil }
        self.value = asciiValue.output.1
    }

    var debugDescription: String { self.description }

    var description: String { String(UnicodeScalar(self.value)) }

    var score: Int {
        let A: UInt8 = 0x41 /* ASCII A */ - 26
        let a: UInt8 = 0x61 // ASCII a

        return Int(self.value - (self.value < a ? A : a) + 1)
    }
}
