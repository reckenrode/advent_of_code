// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day16

open Expecto

open Advent2023.Solutions.Day16

[<Tests>]
let tests =
    testList "Day 16" [
        testList "Examples" [
            testList "Part 1" [
                let input =
                    Tiles.init [
                        @".|...\...."
                        @"|.-.\....."
                        @".....|-..."
                        @"........|."
                        @".........."
                        @".........\"
                        @"..../.\\.."
                        @".-.-/..|.."
                        @".|....-|.\"
                        @"..//.|...."
                    ]

                let expected =
                    [ @"######...."
                      @".#...#...."
                      @".#...#####"
                      @".#...##..."
                      @".#...##..."
                      @".#...##..."
                      @".#..####.."
                      @"########.."
                      @".#######.."
                      @".#...#.#.." ]

                let startBeam =
                    { Position = { X = 0; Y = 0 }
                      Direction = Right }

                test "Path tracing" {
                    let expectedTiles = expected
                    let tiles = Tiles.shoot startBeam input
                    Expect.equal (Tiles.energized tiles) expectedTiles "energized tiles match"
                }

                test "Summarizing" {
                    let expectedTiles = 46
                    let tiles = Tiles.shoot startBeam input

                    Expect.equal
                        (Tiles.count TileType.Energized tiles)
                        expectedTiles
                        "energized tiles match"
                }
            ]
        ]
    ]
