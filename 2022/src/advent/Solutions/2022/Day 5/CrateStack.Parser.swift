// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder

extension CrateStack {
    struct Parser {
        private static let crateRegex = Regex {
            let noCrate = "   "
            let crate = Regex { "["; TryCapture(/[A-Z]/, transform: Crate.init(text:)); "]" }
            let label = #/ \d /#
            ChoiceOf { crate; noCrate; label }; Optionally(" ")
        }

        static func parseStack(from contents: Substring) -> CrateStack {
            let result = contents
                .split(separator: /\n/)
                .reduce(into: CrateStack()) { stack, line in
                    let crates: [(Int, Crate)] = line
                        .matches(of: Self.crateRegex)
                        .enumerated()
                        .compactMap { index, match in
                            guard let crate = match.1 else { return nil }
                            return (index + 1, crate)
                        }
                    if crates.count > 0 {
                        stack.add(crates: crates)
                    }
                }
            return result
        }
    }
}
