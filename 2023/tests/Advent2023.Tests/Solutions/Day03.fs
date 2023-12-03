// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day3


open Expecto

open Advent2023.Solutions.Day3
open System

[<Tests>]
let tests =
    testList "Day 3" [
        testList "Examples" [
            let schematic =
                { Numbers =
                    [ { Value = 467
                        Location = { X = 0; Y = 0 }
                        Length = 3 }
                      { Value = 114
                        Location = { X = 5; Y = 0 }
                        Length = 3 }
                      { Value = 35
                        Location = { X = 2; Y = 2 }
                        Length = 2 }
                      { Value = 633
                        Location = { X = 6; Y = 2 }
                        Length = 3 }
                      { Value = 617
                        Location = { X = 0; Y = 4 }
                        Length = 3 }
                      { Value = 58
                        Location = { X = 7; Y = 5 }
                        Length = 2 }
                      { Value = 592
                        Location = { X = 2; Y = 6 }
                        Length = 3 }
                      { Value = 755
                        Location = { X = 6; Y = 7 }
                        Length = 3 }
                      { Value = 664
                        Location = { X = 1; Y = 9 }
                        Length = 3 }
                      { Value = 598
                        Location = { X = 5; Y = 9 }
                        Length = 3 } ]
                  Parts =
                    [ { Name = "*"
                        Location = { X = 3; Y = 1 } }
                      { Name = "#"
                        Location = { X = 6; Y = 3 } }
                      { Name = "*"
                        Location = { X = 3; Y = 4 } }
                      { Name = "+"
                        Location = { X = 5; Y = 5 } }
                      { Name = "$"
                        Location = { X = 3; Y = 8 } }
                      { Name = "*"
                        Location = { X = 5; Y = 8 } } ] }

            test "Part 1" {
                let expectedSum = 4361
                let sum = Schematic.partNumbers schematic |> List.sum
                Expect.equal sum expectedSum "part numbers add up"
            }

            test "Part 2" {
                let expectedSum = 467835
                let sum = Schematic.gears schematic |> List.map Gear.ratio |> List.sum
                Expect.equal sum expectedSum "gear ratios add up"
            }
        ]
        testList "Bugs" [
            test "It does not count a number one a way" {
                let expectedResult = []

                let schematic =
                    { Numbers =
                        [ { Value = 128
                            Location = { X = 108; Y = 0 }
                            Length = 3 } ]
                      Parts =
                        [ { Name = "*"
                            Location = { X = 112; Y = 0 } } ] }

                let result = Schematic.partNumbers schematic
                Expect.equal result expectedResult "no off by one"
            }
        ]
    ]
