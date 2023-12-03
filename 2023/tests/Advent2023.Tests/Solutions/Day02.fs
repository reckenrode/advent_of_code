// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Day2

open Expecto

open Advent2023.Solutions.Day2

[<Tests>]
let tests =
    testList "Day 2" [
        testList "Examples" [
            let games =
                [ [ { Red = 4; Green = 0; Blue = 3 }
                    { Red = 1; Green = 2; Blue = 6 }
                    { Red = 0; Green = 2; Blue = 0 } ]
                  [ { Red = 0; Green = 2; Blue = 1 }
                    { Red = 1; Green = 3; Blue = 4 }
                    { Red = 0; Green = 1; Blue = 1 } ]
                  [ { Red = 20; Green = 8; Blue = 6 }
                    { Red = 4; Green = 13; Blue = 5 }
                    { Red = 1; Green = 5; Blue = 0 } ]
                  [ { Red = 3; Green = 1; Blue = 6 }
                    { Red = 6; Green = 3; Blue = 0 }
                    { Red = 14; Green = 3; Blue = 15 } ]
                  [ { Red = 6; Green = 3; Blue = 1 }; { Red = 1; Green = 2; Blue = 2 } ] ]

            test "Part 1" {
                let expectedGames = [ 1; 2; 5 ]
                let bag = { Red = 12; Green = 13; Blue = 14 }

                let games = games |> filterValidGames bag |> List.map fst

                Expect.equal games expectedGames "games are valid"
            }

            test "Part 2" {
                let expectedPowers = [ 48; 12; 1560; 630; 36 ]
                let bag = { Red = 12; Green = 13; Blue = 14 }
                let powers = List.map calculatePower games
                Expect.equal powers expectedPowers "powers match"
            }
        ]
    ]
