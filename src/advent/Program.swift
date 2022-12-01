// SPDX-License-Identifier: GPL-3.0-only

import ArgumentParser

@main
struct Advent: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Advent of Code solutions.",
        subcommands: [Advent.Year2022.self]
    )
}
