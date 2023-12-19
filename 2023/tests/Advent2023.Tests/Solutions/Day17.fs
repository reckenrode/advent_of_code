// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day17

open Expecto

open Advent2023.Solutions.Day17

[<Tests>]
let tests =
    testList "Day 17" [
        testList "Examples" [
            let example =
                CityMap.init [
                    [ 2; 4; 1; 3; 4; 3; 2; 3; 1; 1; 3; 2; 3 ]
                    [ 3; 2; 1; 5; 4; 5; 3; 5; 3; 5; 6; 2; 3 ]
                    [ 3; 2; 5; 5; 2; 4; 5; 6; 5; 4; 2; 5; 4 ]
                    [ 3; 4; 4; 6; 5; 8; 5; 8; 4; 5; 4; 5; 2 ]
                    [ 4; 5; 4; 6; 6; 5; 7; 8; 6; 7; 5; 3; 6 ]
                    [ 1; 4; 3; 8; 5; 9; 8; 7; 9; 8; 4; 5; 4 ]
                    [ 4; 4; 5; 7; 8; 7; 6; 9; 8; 7; 7; 6; 6 ]
                    [ 3; 6; 3; 7; 8; 7; 7; 9; 7; 9; 6; 5; 3 ]
                    [ 4; 6; 5; 4; 9; 6; 7; 9; 8; 6; 8; 8; 7 ]
                    [ 4; 5; 6; 4; 6; 7; 9; 9; 8; 6; 4; 5; 3 ]
                    [ 1; 2; 2; 4; 6; 8; 6; 8; 6; 5; 5; 6; 3 ]
                    [ 2; 5; 4; 6; 5; 4; 8; 8; 8; 7; 7; 3; 5 ]
                    [ 4; 3; 2; 2; 6; 7; 4; 6; 5; 5; 5; 3; 3 ]
                ]

            test "Part 1" {
                let expectedHeatLoss = 102L

                let heatLoss =
                    CityMap.leastHeatLoss
                        { MinForward = 0
                          MaxForward = 3
                          StoppingDistance = 0 }
                        example

                Expect.equal heatLoss expectedHeatLoss "heat loss matches"
            }

            testList "Part 2" [
                test "Example 1" {
                    let expectedHeatLoss = 94L

                    let heatLoss =
                        CityMap.leastHeatLoss
                            { MinForward = 4
                              MaxForward = 10
                              StoppingDistance = 4 }
                            example

                    Expect.equal heatLoss expectedHeatLoss "heat loss matches"
                }
                test "Example 2" {
                    let example =
                        CityMap.init [
                            [ 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1 ]
                            [ 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 1 ]
                            [ 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 1 ]
                            [ 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 1 ]
                            [ 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 1 ]
                        ]

                    let expectedHeatLoss = 71L

                    let heatLoss =
                        CityMap.leastHeatLoss
                            { MinForward = 4
                              MaxForward = 10
                              StoppingDistance = 4 }
                            example

                    Expect.equal heatLoss expectedHeatLoss "heat loss matches"
                }
            ]
        ]
    ]
