// SPDX-License-Identifier: GPL-3.0-only

import ArgumentParser

extension Advent {
    struct Year2022: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "2022",
            abstract: "Run 2022 solutions to Advent of Code.",
            subcommands: [
                Solutions.Year2022.Day1.self,
                Solutions.Year2022.Day2.self,
                Solutions.Year2022.Day3.self,
                Solutions.Year2022.Day4.self,
                Solutions.Year2022.Day5.self,
            ]
        )
    }
}

extension Solutions {
    enum Year2022 { }
}
