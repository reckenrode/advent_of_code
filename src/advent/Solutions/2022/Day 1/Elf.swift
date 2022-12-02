// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

struct Elf {
    struct Parser: CustomConsumingRegexComponent {
        typealias RegexOutput = Elf

        static let regex = Regex {
            let digits = Regex {
                CharacterClass("1"..."9")
                OneOrMore(.digit)
            }
            OneOrMore {
                digits
                One(.newlineSequence)
            }
        }

        func consuming(
            _ input: String,
            startingAt index: String.Index,
            in bounds: Range<String.Index>
        ) throws -> (upperBound: String.Index, output: Self.RegexOutput)? {
            guard let match = input[index..<bounds.upperBound].firstMatch(of: Self.regex) else {
                return nil
            }

            let inventory = match.output
                .split(separator: { One(.newlineSequence) })
                .compactMap { Int($0) }

            return (input.index(index, offsetBy: match.count), Elf(inventory: inventory))
        }
    }

    let inventory: [Int]
    var carriedCalories: Int {
        self.inventory.reduce(0, +)
    }
}

extension Elf {
    init?(of string: String) {
        let parseResult = try? Elf.Parser().consuming(
            string,
            startingAt: string.startIndex,
            in: string.startIndex..<string.endIndex
        )
        guard let parseResult else { return nil }

        self = parseResult.output
    }
}
