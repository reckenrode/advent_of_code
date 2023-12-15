// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day14

open Expecto

open Advent2023.Solutions.Day14


[<Tests>]
let tests =
    testList "Day 14" [
        testList "Examples" [
            let field =
                Field.init [
                    "O....#...."
                    "O.OO#....#"
                    ".....##..."
                    "OO.#O....O"
                    ".O.....O#."
                    "O.#..O.#.#"
                    "..O..#O..O"
                    ".......O.."
                    "#....###.."
                    "#OO..#...."
                ]

            testList "Part 1" [
                let expectedFields =
                    Map [
                        North,
                        Field.init [
                            "OOOO.#.O.."
                            "OO..#....#"
                            "OO..O##..O"
                            "O..#.OO..."
                            "........#."
                            "..#....#.#"
                            "..O..#.O.O"
                            "..O......."
                            "#....###.."
                            "#....#...."
                        ]
                        South,
                        Field.init [
                            ".....#...."
                            "....#....#"
                            "...O.##..."
                            "...#......"
                            "O.O....O#O"
                            "O.#..O.#.#"
                            "O....#...."
                            "OO....OO.."
                            "#OO..###.."
                            "#OO.O#...O"
                        ]
                        East,
                        Field.init [
                            "....O#...."
                            ".OOO#....#"
                            ".....##..."
                            ".OO#....OO"
                            "......OO#."
                            ".O#...O#.#"
                            "....O#..OO"
                            ".........O"
                            "#....###.."
                            "#..OO#...."
                        ]
                        West,
                        Field.init [
                            "O....#...."
                            "OOO.#....#"
                            ".....##..."
                            "OO.#OO...."
                            "OO......#."
                            "O.#O...#.#"
                            "O....#OO.."
                            "O........."
                            "#....###.."
                            "#OO..#...."
                        ]
                    ]

                let expectedLoads = Map [
                    North, 136
                    South, 132
                    East, 105
                    West, 147
                ]

                for direction in Map.keys expectedFields do
                    test $"Tilt {direction}" {
                        let expectedField = Map.find direction expectedFields
                        let field = Field.tilt direction field
                        Expect.equal field expectedField "boulders rolled the right way"
                    }

                    test $"Load calculation {direction}" {
                        let expectedLoad = Map.find direction expectedLoads
                        let field = Map.find direction expectedFields
                        let load = Field.totalLoad direction field
                        Expect.equal load expectedLoad "loads match"
                    }
            ]
        ]
    ]
