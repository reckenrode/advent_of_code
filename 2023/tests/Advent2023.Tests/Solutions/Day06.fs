// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day6


open Expecto

open Advent2023.Solutions.Day6


[<Tests>]
let tests =
    testList "Day 6" [
        testList "Examples" [
            let races =
                [ { Time = 7L; Distance = 9L }
                  { Time = 15L; Distance = 40L }
                  { Time = 30L; Distance = 200L } ]

            test "Part 1" {
                let expectedWaysToWin = [ 4L; 8L; 9L ]
                let waysToWin = List.map RaceResult.countWaysToBeat races
                Expect.equal waysToWin expectedWaysToWin "ways to win match"
            }
        ]
    ]
