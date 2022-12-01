// SPDX-License-Identifier: GPL-3.0-only

import ArgumentParser

extension Advent {
    struct Year2022: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "2022",
            abstract: "Run 2022 solutions to Advent of Code.",
            subcommands: []
        )
    }
}
