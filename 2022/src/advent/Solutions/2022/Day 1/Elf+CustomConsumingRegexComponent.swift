// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

extension Elf {
    struct Parser: CustomConsumingRegexComponent {
        typealias RegexOutput = Elf

        private static let regex = Regex {
            TryCapture(OneOrMore(.digit), transform: { Int($0) })
            One(.newlineSequence)
        }

        func consuming(
            _ input: String,
            startingAt index: String.Index,
            in bounds: Range<String.Index>
        ) throws -> (upperBound: String.Index, output: Self.RegexOutput)? {
            var inventory: [Int] = []

            var index = index
            while let match = input[index..<bounds.upperBound].prefixMatch(of: Self.regex) {
                inventory.append(match.1)
                index = input.index(index, offsetBy: match.0.count)
            }

            return (index, Elf(inventory: inventory))
        }
    }
}
