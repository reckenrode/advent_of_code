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
                Solutions.Year2022.Day6.self,
                Solutions.Year2022.Day7.self,
                Solutions.Year2022.Day8.self,
                Solutions.Year2022.Day9.self,
                Solutions.Year2022.Day10.self,
                Solutions.Year2022.Day11.self,
                Solutions.Year2022.Day12.self,
                Solutions.Year2022.Day13.self,
                Solutions.Year2022.Day14.self,
                Solutions.Year2022.Day15.self,
            ]
        )
    }
}

extension Solutions {
    enum Year2022 { }
}
