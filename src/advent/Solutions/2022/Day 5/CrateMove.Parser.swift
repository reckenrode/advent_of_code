// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

extension CrateMove {
    struct Parser {
        private static let moveRegex = Regex {
            let number = TryCapture(/\d+/, transform: { Int($0) })
            "move "; number; " from "; number; " to "; number; Optionally("\n")
        }

        static func parseMoves(from contents: Substring) -> [CrateMove] {
            let result: [CrateMove] = contents
                .matches(of: Self.moveRegex)
                .map { match in
                    let (_, quantity, source, destination) = match.output
                    return CrateMove(
                        quantity: quantity,
                        source: source,
                        destination: destination
                    )
                }
            return result
        }
    }
}
